#import "public/MSHBarView.h"

@implementation MSHBarView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.barCornerRadius = 13;
        self.barSpacing = 5;
    }

    return self;
}

-(void)initializeWaveLayers{
    [self resetWaveLayers];

    if (self.autoHide) {
        [self setAlpha:0.0f];
    }

    [self configureDisplayLink];
}

-(void)resetWaveLayers{
    self.layer.sublayers = nil;

    CGFloat width = (self.frame.size.width - self.barSpacing)/(CGFloat)self.numberOfPoints;
    for (int i = 0; i < self.numberOfPoints; i++) {
        CALayer *layer = [[CALayer alloc] init];
        layer.cornerRadius = self.barCornerRadius;
        layer.frame = CGRectMake(i*width + self.barSpacing, 0, width - self.barSpacing, self.frame.size.height);
        [self.layer addSublayer:layer];
    }

    cachedNumberOfPoints = self.numberOfPoints;
}

-(void)updateWaveColor:(UIColor *)waveColor subwaveColor:(UIColor *)subwaveColor{
    for (CALayer *layer in [self.layer sublayers]) {
        layer.backgroundColor = waveColor.CGColor;
    }
}

- (void)redraw{
    [super redraw];
    
    if (cachedNumberOfPoints != self.numberOfPoints) {
        [self resetWaveLayers];
    }

    int i = 0;
    CGFloat width = (self.frame.size.width - self.barSpacing)/(CGFloat)self.numberOfPoints;
    for (CALayer *layer in [self.layer sublayers]) {
        layer.frame = CGRectMake(i*width + self.barSpacing, self.points[i].y, width - self.barSpacing, self.frame.size.height-self.points[i].y);
        i++;
    }
}

@end