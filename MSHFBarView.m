#import "public/MSHFBarView.h"

@implementation MSHFBarView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];

  if (self) {
    self.barCornerRadius = 13;
    self.barSpacing = 5;
  }

  return self;
}

- (void)initializeWaveLayers {
  if (self.siriEnabled) {
    self.redBars = [[CALayer alloc] init];
    self.greenBars = [[CALayer alloc] init];
    self.blueBars = [[CALayer alloc] init];
    
    [self.layer addSublayer:self.redBars];
    [self.layer addSublayer:self.greenBars];
    [self.layer addSublayer:self.blueBars];
    
    self.redBars.zPosition = 0;
    self.greenBars.zPosition = -1;
    self.blueBars.zPosition = -2;
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
      layer.cornerRadius = self.barCornerRadius;
      layer.frame = CGRectMake(i * width + self.barSpacing, 0, barWidth,
                               self.frame.size.height);
      if (self.waveColor) {
        layer.backgroundColor = self.waveColor.CGColor;
      }
      [self.layer addSublayer:layer];
    }
  } else {
    self.redBars.sublayers = nil;
    self.greenBars.sublayers = nil;
    self.blueBars.sublayers = nil;
    
    for (int r = 0; r < self.numberOfPoints; r++) {
        CALayer *layer = [[CALayer alloc] init];
      layer.cornerRadius = self.barCornerRadius;
      layer.frame = CGRectMake(r * width + self.barSpacing, 0, barWidth,
                               self.frame.size.height);
      if (self.waveColor) {
        layer.backgroundColor = self.waveColor.CGColor;
      }
      [self.redBars addSublayer:layer];
    }
    
    for (int g = 0; g < self.numberOfPoints; g++) {
      CALayer *layer = [[CALayer alloc] init];
      layer.cornerRadius = self.barCornerRadius;
      layer.frame = CGRectMake(g * width + self.barSpacing, 0, barWidth,
                               self.frame.size.height);
      if (self.subwaveColor) {
        layer.backgroundColor = self.subwaveColor.CGColor;
      }
      [self.greenBars addSublayer:layer];
    }
    
    for (int b = 0; b < self.numberOfPoints; b++) {
      CALayer *layer = [[CALayer alloc] init];
      layer.cornerRadius = self.barCornerRadius;
      layer.frame = CGRectMake(b * width + self.barSpacing, 0, barWidth,
                               self.frame.size.height);
      if (self.subSubwaveColor) {
        layer.backgroundColor = self.subSubwaveColor.CGColor;
      }
      [self.blueBars addSublayer:layer];
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
  if (!self.redBars) {
    [self initializeWaveLayers];
  }
  
  self.waveColor = waveColor;
  self.subwaveColor = subwaveColor;
  self.subSubwaveColor = subSubwaveColor;
  
  self.redBars.compositingFilter = @"screenBlendMode";
  self.greenBars.compositingFilter = @"screenBlendMode";
  self.blueBars.compositingFilter = @"screenBlendMode";
  
  for (CALayer *layer in [self.redBars sublayers]) {
    layer.backgroundColor = waveColor.CGColor;
  }
  for (CALayer *layer in [self.greenBars sublayers]) {
    layer.backgroundColor = subwaveColor.CGColor;
  }
  for (CALayer *layer in [self.blueBars sublayers]) {
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
      CGFloat barHeight = self.frame.size.height - self.points[i].y;
      if (barHeight <= 0)
        barHeight = 1;

      layer.frame = CGRectMake(i * width + self.barSpacing, self.points[i].y,
                               barWidth, barHeight);
      i++;
    }
  } else {
    int r = 0;
    int g = 0;
    int b = 0;
    
    for (CALayer *layer in [self.redBars sublayers]) {
      if (!layer)
        continue;
      if (isnan(self.points[r].y))
        self.points[r].y = 0;
      CGFloat barHeight = self.frame.size.height - self.points[r].y;
      if (barHeight <= 0)
        barHeight = 1;

      layer.frame = CGRectMake(r * width + self.barSpacing, self.points[r].y,
                               barWidth, barHeight);
      r++;
    }
    
    for (CALayer *layer in [self.greenBars sublayers]) {
      if (!layer)
        continue;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isnan(self.points[g].y))
          self.points[g].y = 0;
        CGFloat barHeight = self.frame.size.height - self.points[g].y;
        if (barHeight <= 0)
          barHeight = 1;

        layer.frame = CGRectMake(g * width + self.barSpacing, self.points[g].y,
                                 barWidth, barHeight);
      });
      g++;
    }
    
    for (CALayer *layer in [self.blueBars sublayers]) {
      if (!layer)
        continue;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.50 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isnan(self.points[b].y))
          self.points[b].y = 0;
        CGFloat barHeight = self.frame.size.height - self.points[b].y;
        if (barHeight <= 0)
          barHeight = 1;

        layer.frame = CGRectMake(b * width + self.barSpacing, self.points[b].y,
                                 barWidth, barHeight);
      });
      b++;
    }
  }
}

@end
