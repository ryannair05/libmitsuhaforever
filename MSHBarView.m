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
    for (CALayer *layer in [self.layer sublayers]) {
        [layer removeFromSuperlayer];
    }

    for (int i = 0; i < self.numberOfPoints; i++) {
        CALayer *layer = [[CALayer alloc] init];
        layer.cornerRadius = self.barCornerRadius;
        [self.layer addSublayer:layer];
    }
}

-(void)updateWaveColor:(UIColor *)waveColor subwaveColor:(UIColor *)subwaveColor{
    for (CALayer *layer in [self.layer sublayers]) {
        layer.backgroundColor = waveColor.CGColor;
    }
}

- (void)redraw{
    [super redraw];
    
    if (cachedLength != self.numberOfPoints) {
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