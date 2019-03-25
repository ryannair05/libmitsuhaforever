#import "public/MSHView.h"
#import "public/MSHAudioSourceASS.h"
#import <Nepeta/NEPColorUtils.h>

@implementation MSHView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.numberOfPoints = 16;
        self.waveOffset = 0;
        self.gain = 0;
        self.limiter = 0;
        self.sensitivity = 1;
        self.disableBatterySaver = false;
        self.autoHide = true;

        self.audioSource = [[MSHAudioSourceASS alloc] init];
        self.audioSource.delegate = self;

        self.audioProcessing = [[MSHAudioProcessing alloc] initWithBufferSize:1024];
        self.audioProcessing.delegate = self;
        self.audioProcessing.fft = true;

        [self initializeWaveLayers];

        mshHidden = false;

        self.shouldUpdate = true;

        cachedLength = self.numberOfPoints;
        self.points = (CGPoint *)malloc(sizeof(CGPoint) * self.numberOfPoints);
    }

    return self;
}

-(void)stop{
    if (self.disableBatterySaver) return;
    [self.audioSource stop];
}

-(void)start{
    [self.audioSource start];
}

-(void)initializeWaveLayers{
}

-(void)resetWaveLayers{
}

-(void)configureDisplayLink{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(redraw)];
    
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.displayLink setPaused:false];

    self.displayLink.preferredFramesPerSecond = 60;
}

-(void)updateWaveColor:(UIColor *)waveColor subwaveColor:(UIColor *)subwaveColor{
}

- (void)redraw{
    if (self.shouldUpdate) {
        [self requestUpdate];
    }

    if (self.autoHide) {
        if (silentSince < ((long long)[[NSDate date] timeIntervalSince1970] - 1)) {
            if (!mshHidden) {
                mshHidden = true;
                [UIView animateWithDuration:0.5 animations:^{
                    [self setAlpha:0.0f];
                }];
            }
        } else if (mshHidden) {
            mshHidden = false;
            [UIView animateWithDuration:0.5 animations:^{
                [self setAlpha:1.0f];
            }];
        }
    }
}

-(void)requestUpdate{
    [self.audioSource requestUpdate];
}

-(void)updateBuffer:(float *)bufferData withLength:(int)length{
    if (self.autoHide) {
        for (int i = 0; i < length; i++) {
            if (bufferData[i] != 0) {
                silentSince = (long long)[[NSDate date] timeIntervalSince1970];
                break;
            }
        }
    }

    [self.audioProcessing process:bufferData withLength:length];
}

- (void)setSampleData:(float *)data length:(int)length{
    NSUInteger compressionRate = length/self.numberOfPoints;
    
    float pixelFixer = self.bounds.size.width/self.numberOfPoints;
    
    if(cachedLength != self.numberOfPoints){
        free(self.points);
        self.points = (CGPoint *)malloc(sizeof(CGPoint) * self.numberOfPoints);
        cachedLength = self.numberOfPoints;
    }
    
    for (int i = 0; i < self.numberOfPoints; i++){
        self.points[i].x = i*pixelFixer;
        double pureValue = data[i*compressionRate] * self.gain;
        
        if(self.limiter != 0){
            pureValue = (fabs(pureValue) < self.limiter ? pureValue : (pureValue < 0 ? -1*self.limiter : self.limiter));
        }
        
        self.points[i].y = (pureValue * self.sensitivity) + self.waveOffset;
    }
}

@end