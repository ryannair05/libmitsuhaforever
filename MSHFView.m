#import "public/MSHFView.h"

@implementation MSHFView

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

    self.audioProcessing = [[MSHFAudioProcessing alloc] initWithBufferSize:1024];
    self.audioProcessing.delegate = self;
    self.audioProcessing.fft = true;

    [self initializeWaveLayers];

    cachedLength = self.numberOfPoints;
    self.points = (CGPoint *)malloc(sizeof(CGPoint) * self.numberOfPoints);

    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:MSHFPrefsFile];
    boost = ([prefs objectForKey:@"MSHFAirpodsSensBoost"] ? [[prefs objectForKey:@"MSHFAirpodsSensBoost"] boolValue] : NO);
  }

  return self;
}

-(void)dealloc {
    [_displayLink invalidate];
    free(self.points);
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
    if (self.audioSource.isRunning && !self.disableBatterySaver) {
        [self.audioSource stop];
        [self.displayLink setPaused:true];
        silentSince = -2;
        [self redraw];
    }
}

- (void)start {
  NSString *identifier = [[NSProcessInfo processInfo] processName];
  if ([identifier isEqualToString:@"Music"] || [identifier isEqualToString:@"Spotify"] || [[NSClassFromString(@"SBMediaController") sharedInstance] isPlaying]) {
	    [self.audioSource start];
      [self.displayLink setPaused:false];
  }
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
  [self.displayLink setPaused:true];

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
    if (silentSince < ((long long)[[NSDate date] timeIntervalSinceReferenceDate] - 1)) {
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
      if (bufferData[i] > 0.000005) {
        silentSince = (long long)[[NSDate date] timeIntervalSinceReferenceDate];
        break;
      }
    }
  }

  [self.audioProcessing process:bufferData withLength:length];
}

- (void)setSampleData:(float *)data length:(int)length {
  NSUInteger const compressionRate = length / self.numberOfPoints;

  float const pixelFixer = self.bounds.size.width / self.numberOfPoints;

  if (cachedLength != self.numberOfPoints) {
    free(self.points);
    self.points = (CGPoint *)malloc(sizeof(CGPoint) * self.numberOfPoints);
    cachedLength = self.numberOfPoints;
  }


  if ([[[NSClassFromString(@"BluetoothManager") sharedInstance] connectedDevices] count] && boost) {

    for (int i = 0; i < self.numberOfPoints; i++) {
        self.points[i].x = i * pixelFixer;
        double pureValue = data[i * compressionRate] * self.gain;

        if (!pureValue) {
          self.points[i].y = self.waveOffset;
          continue;
        }

        if (self.limiter != 0) {
          pureValue = (fabs(pureValue) < self.limiter
                          ? pureValue
                          : (pureValue < 0 ? -1 * self.limiter : self.limiter));
        }

        self.points[i].y = (pureValue * self.sensitivity);

        while (fabs(self.points[i].y) < 1.5) {
            self.points[i].y *= 25;
        }
        self.points[i].y += self.waveOffset;
      }
  } else {

    for (int i = 0; i < self.numberOfPoints; i++) {
      self.points[i].x = i * pixelFixer;
      double pureValue = data[i * compressionRate] * self.gain;

      if (self.limiter != 0) {
        pureValue = (fabs(pureValue) < self.limiter
                        ? pureValue
                        : (pureValue < 0 ? -1 * self.limiter : self.limiter));
      }

      self.points[i].y = (pureValue * self.sensitivity) + self.waveOffset;

      if (isnan(self.points[i].y))
        self.points[i].y = self.waveOffset;
    }
  }
}

@end
