#import "public/MSHFView.h"
#import "public/MSHFAudioSourceASS.h"
#import "public/MSHFUtils.h"
#import <Cephei/HBPreferences.h>

@implementation MSHFView

HBPreferences *file;
BOOL boost;

- (instancetype)initWithFrame:(CGRect)frame {
  self = [self initWithFrame:frame
                 audioSource:[[MSHFAudioSourceASS alloc] init]];
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                  audioSource:(MSHFAudioSource *)audioSource {
  self = [super initWithFrame:frame];

  if (self) {
    self.numberOfPoints = 8;
    self.waveOffset = 0;
    self.gain = 0;
    self.limiter = 0;
    self.sensitivity = 1;
    self.disableBatterySaver = false;
    self.autoHide = true;
    MSHFHidden = self.autoHide;

    if (self.autoHide) {
      [self setAlpha:0.0f];
    } else {
      [self setAlpha:1.0f];
    }

    self.audioSource = audioSource;
    self.audioSource.delegate = self;

    self.audioProcessing =
        [[MSHFAudioProcessing alloc] initWithBufferSize:1024];
    self.audioProcessing.delegate = self;
    self.audioProcessing.fft = true;

    [self initializeWaveLayers];

    self.shouldUpdate = true;

    cachedLength = self.numberOfPoints;
    self.points = (CGPoint *)malloc(sizeof(CGPoint) * self.numberOfPoints);

    file = [[HBPreferences alloc] initWithIdentifier:MSHFPreferencesIdentifier];

    [file registerDefaults:@{@"MSHFAirpodsSensBoost" : @NO}];
    [file registerBool:&boost default:NO forKey:@"MSHFAirpodsSensBoost"];
  }

  return self;
}

- (void)setAutoHide:(BOOL)value {
  if (value &&
      (silentSince < ((long long)[[NSDate date] timeIntervalSince1970] - 1))) {
    MSHFHidden = true;
    [self setAlpha:0.0f];
  } else {
    MSHFHidden = false;
    [self setAlpha:1.0f];
  }

  _autoHide = value;
}

- (void)stop {
  if (self.disableBatterySaver)
    return;
  [self.audioSource stop];
}

- (void)start {
  [self.audioSource start];
}

- (void)initializeWaveLayers {
}

- (void)resetWaveLayers {
}

- (void)configureDisplayLink {
  self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                 selector:@selector(redraw)];

  [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                         forMode:NSDefaultRunLoopMode];
  [self.displayLink setPaused:false];

  self.displayLink.preferredFramesPerSecond = 60;
}

- (void)updateWaveColor:(UIColor *)waveColor
           subwaveColor:(UIColor *)subwaveColor {
}

- (void)updateWaveColor:(UIColor *)waveColor
           subwaveColor:(UIColor *)subwaveColor
        subSubwaveColor:(UIColor *)subSubwaveColor {
}

- (void)redraw {
  if (self.autoHide) {
    if (silentSince < ((long long)[[NSDate date] timeIntervalSince1970] - 1)) {
      if (!MSHFHidden) {
        MSHFHidden = true;
        [UIView animateWithDuration:0.5
                         animations:^{
                           [self setAlpha:0.0f];
                         }];
      }
    } else if (MSHFHidden) {
      MSHFHidden = false;
      [UIView animateWithDuration:0.5
                       animations:^{
                         [self setAlpha:1.0f];
                       }];
    }
  }
}

- (void)updateBuffer:(float *)bufferData withLength:(int)length {
  if (self.autoHide) {
    for (int i = 0; i < length / 4; i++) {
      if (bufferData[i] > 0.000005 || bufferData[i] < -0.000005) {
        silentSince = (long long)[[NSDate date] timeIntervalSince1970];
        break;
      }
    }
  }

  [self.audioProcessing process:bufferData withLength:length];
}

- (void)setSampleData:(float *)data length:(int)length {
  NSUInteger const compressionRate = length / self.numberOfPoints;

  float const pixelFixer = self.bounds.size.width / self.numberOfPoints;

  bool const isAppleMusic = [@"Music" isEqualToString:[NSProcessInfo processInfo].processName];

  if (cachedLength != self.numberOfPoints) {
    free(self.points);
    self.points = (CGPoint *)malloc(sizeof(CGPoint) * self.numberOfPoints);
    cachedLength = self.numberOfPoints;
  }

  for (int i = 0; i < self.numberOfPoints; i++) {
    self.points[i].x = i * pixelFixer;
    double pureValue = data[i * compressionRate] * self.gain;

    if (self.limiter != 0) {
      pureValue = (fabs(pureValue) < self.limiter
                       ? pureValue
                       : (pureValue < 0 ? -1 * self.limiter : self.limiter));
    }

    if (boost) {
      if (isAppleMusic)
        self.points[i].y = pow(pureValue, self.sensitivity) + self.waveOffset;
      else 
        self.points[i].y = 25 + self.waveOffset;
    } 
    else { 
      self.points[i].y = (pureValue * self.sensitivity) + self.waveOffset;
    }

    if (isnan(self.points[i].y))
      self.points[i].y = 0;
  }
}

@end
