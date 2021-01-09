#import "public/MSHFDotView.h"

@implementation MSHFDotView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];

  if (self) {
    self.barSpacing = 5;
  }

  return self;
}

- (void)initializeWaveLayers {
  if (self.siriEnabled) {
    self.redDots = [[CALayer alloc] init];
    self.greenDots = [[CALayer alloc] init];
    self.blueDots = [[CALayer alloc] init];
    
    [self.layer addSublayer:self.redDots];
    [self.layer addSublayer:self.greenDots];
    [self.layer addSublayer:self.blueDots];
    
    self.redDots.zPosition = 0;
    self.greenDots.zPosition = -1;
    self.blueDots.zPosition = -2;
  }
  [self resetWaveLayers];
  [self configureDisplayLink];
}

- (void)resetWaveLayers {
  CGFloat width = ((self.frame.size.width - self.barSpacing) /
                   (CGFloat)self.numberOfPoints);
  CGFloat barWidth = width - self.barSpacing;
  if (width <= 0)
    width = 1;
  if (barWidth <= 0)
    barWidth = 1;
  
  if (!self.siriEnabled) {
    self.layer.sublayers = nil;

    for (int i = 0; i < self.numberOfPoints; i++) {
      CALayer *layer = [[CALayer alloc] init];
      layer.cornerRadius = barWidth / 2.0;
      layer.frame =
          CGRectMake(i * width + self.barSpacing, 0, barWidth, barWidth);
      if (self.waveColor) {
        layer.backgroundColor = self.waveColor.CGColor;
      }
      [self.layer addSublayer:layer];
    }
  } else {
    self.redDots.sublayers = nil;
    self.greenDots.sublayers = nil;
    self.blueDots.sublayers = nil;
    
    for (int r = 0; r < self.numberOfPoints; r++) {
      CALayer *layer = [[CALayer alloc] init];
      layer.cornerRadius = barWidth / 2.0;
      layer.frame =
          CGRectMake(r * width + self.barSpacing, 0, barWidth, barWidth);
      if (self.waveColor) {
        layer.backgroundColor = self.waveColor.CGColor;
      }
      [self.redDots addSublayer:layer];
    }
    
    for (int g = 0; g < self.numberOfPoints; g++) {
      CALayer *layer = [[CALayer alloc] init];
      layer.cornerRadius = barWidth / 2.0;
      layer.frame =
          CGRectMake(g * width + self.barSpacing, 0, barWidth, barWidth);
      if (self.waveColor) {
        layer.backgroundColor = self.waveColor.CGColor;
      }
      [self.greenDots addSublayer:layer];
    }
    
    for (int b = 0; b < self.numberOfPoints; b++) {
      CALayer *layer = [[CALayer alloc] init];
      layer.cornerRadius = barWidth / 2.0;
      layer.frame =
          CGRectMake(b * width + self.barSpacing, 0, barWidth, barWidth);
      if (self.waveColor) {
        layer.backgroundColor = self.waveColor.CGColor;
      }
      [self.blueDots addSublayer:layer];
    }
  }

  self.cachedNumberOfPoints = self.numberOfPoints;
}

- (void)updateWaveColor:(UIColor *)waveColor
           subwaveColor:(UIColor *)subwaveColor {
  self.waveColor = waveColor;
  for (CALayer *layer in [self.layer sublayers]) {
    layer.backgroundColor = waveColor.CGColor;
  }
}

- (void)updateWaveColor:(UIColor *)waveColor
           subwaveColor:(UIColor *)subwaveColor
        subSubwaveColor:(UIColor *)subSubwaveColor {
  if (!self.redDots) {
    [self initializeWaveLayers];
  }
  self.waveColor = waveColor;
  self.subwaveColor = subwaveColor;
  self.subSubwaveColor = subSubwaveColor;
  
  self.redDots.compositingFilter = @"screenBlendMode";
  self.greenDots.compositingFilter = @"screenBlendMode";
  self.blueDots.compositingFilter = @"screenBlendMode";
  
  for (CALayer *layer in [self.redDots sublayers]) {
    layer.backgroundColor = waveColor.CGColor;
  }
  for (CALayer *layer in [self.greenDots sublayers]) {
    layer.backgroundColor = subwaveColor.CGColor;
  }
  for (CALayer *layer in [self.blueDots sublayers]) {
    layer.backgroundColor = subSubwaveColor.CGColor;
  }
}

- (void)redraw {
  [super redraw];

  if (self.cachedNumberOfPoints != self.numberOfPoints) {
    [self resetWaveLayers];
  }

  CGFloat width = ((self.frame.size.width - self.barSpacing) /
                   (CGFloat)self.numberOfPoints);
  CGFloat barWidth = width - self.barSpacing;
  if (width <= 0)
    width = 1;
  if (barWidth <= 0)
    barWidth = 1;

  if (!self.siriEnabled) {
    int i = 0;
    
    for (CALayer *layer in [self.layer sublayers]) {
      if (!layer)
        continue;
      if (isnan(self.points[i].y))
        self.points[i].y = 0;

      layer.frame = CGRectMake(i * width + self.barSpacing, self.points[i].y,
                               barWidth, barWidth);
      i++;
    }
  } else {
    int r = 0;
    int g = 0;
    int b = 0;
    
    for (CALayer *layer in [self.redDots sublayers]) {
      if (!layer)
        continue;
      if (isnan(self.points[r].y))
        self.points[r].y = 0;

      layer.frame = CGRectMake(r * width + self.barSpacing, self.points[r].y,
                               barWidth, barWidth);
      r++;
    }
    
      
    for (CALayer *layer in [self.greenDots sublayers]) {
      if (!layer)
        continue;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isnan(self.points[g].y))
          self.points[g].y = 0;

        layer.frame = CGRectMake(g * width + self.barSpacing, self.points[g].y,
                                 barWidth, barWidth);
      });
      g++;
    }
    
    for (CALayer *layer in [self.blueDots sublayers]) {
      if (!layer)
        continue;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.50 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isnan(self.points[b].y))
          self.points[b].y = 0;

        layer.frame = CGRectMake(b * width + self.barSpacing, self.points[b].y,
                                 barWidth, barWidth);
      });
      b++;
    }
  }
}

@end
