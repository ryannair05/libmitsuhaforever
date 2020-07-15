#import "public/MSHFSiriLineView.h"

@implementation MSHFSiriLineView

- (void)initializeWaveLayers {
  self.waveLayer = [MSHFJelloLayer layer];
  self.subwaveLayer = [MSHFJelloLayer layer];
  self.subSubwaveLayer = [MSHFJelloLayer layer];

  self.waveLayer.frame = self.subwaveLayer.frame = self.subSubwaveLayer.frame = self.bounds;

  [self.layer addSublayer:self.waveLayer];
  [self.layer addSublayer:self.subwaveLayer];
  [self.layer addSublayer:self.subSubwaveLayer];

  self.waveLayer.zPosition = 0;
  self.subwaveLayer.zPosition = -1;
  self.subSubwaveLayer.zPosition = -2;
  self.waveLayer.lineWidth = 5;
  self.subwaveLayer.lineWidth = 5;
  self.subSubwaveLayer.lineWidth = 5;
  self.waveLayer.fillColor = [UIColor clearColor].CGColor;
  self.subwaveLayer.fillColor = [UIColor clearColor].CGColor;
  self.subSubwaveLayer.fillColor = [UIColor clearColor].CGColor;

  [self configureDisplayLink];
  [self resetWaveLayers];

  self.waveLayer.shouldAnimate = true;
  self.subwaveLayer.shouldAnimate = true;
  self.subSubwaveLayer.shouldAnimate = true;
}

- (void)setLineThickness:(CGFloat)thickness {
  _lineThickness = thickness;
  self.waveLayer.lineWidth = thickness;
  self.subwaveLayer.lineWidth = thickness;
  self.subSubwaveLayer.lineWidth = thickness;
}

- (void)resetWaveLayers {
  if (!self.waveLayer || !self.subwaveLayer || !self.subSubwaveLayer) {
    [self initializeWaveLayers];
  }

  CGPathRef path = [self createPathWithPoints:self.points
                                   pointCount:0
                                       inRect:self.bounds];

  NSLog(@"[libmitsuha]: Resetting Wave Layers...");

  self.waveLayer.path = path;
  self.subwaveLayer.path = path;
  self.subSubwaveLayer.path = path;
}

- (void)updateWaveColor:(UIColor *)waveColor
           subwaveColor:(UIColor *)subwaveColor
        subSubwaveColor:(UIColor *)subSubwaveColor {
  self.waveColor = waveColor;
  self.subwaveColor = subwaveColor;
  self.subSubwaveColor = subSubwaveColor;
  self.waveLayer.strokeColor = waveColor.CGColor;
  self.subwaveLayer.strokeColor = subwaveColor.CGColor;
  self.subSubwaveLayer.strokeColor = subSubwaveColor.CGColor;
  self.waveLayer.compositingFilter = @"screenBlendMode";
  self.subwaveLayer.compositingFilter = @"screenBlendMode";
  self.subSubwaveLayer.compositingFilter = @"screenBlendMode";
}

- (void)redraw {
  [super redraw];

  CGPathRef path = [self createPathWithPoints:self.points
                                   pointCount:self.numberOfPoints
                                       inRect:self.bounds];
  self.waveLayer.path = path;
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    self.subwaveLayer.path = path;
  });
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.50 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    self.subSubwaveLayer.path = path;
    CGPathRelease(path);
  });
}

- (void)setSampleData:(float *)data length:(int)length {
  [super setSampleData:data length:length];

  self.points[self.numberOfPoints - 1].x = self.bounds.size.width;
  self.points[0].y = self.points[self.numberOfPoints - 1].y = self.waveOffset;
}

- (CGPathRef)createPathWithPoints:(CGPoint *)points
                       pointCount:(NSUInteger)pointCount
                           inRect:(CGRect)rect {
  UIBezierPath *path;

  if (pointCount > 0) {
    path = [UIBezierPath bezierPath];

    [path moveToPoint:self.points[0]];

    for (int i = 0; i < self.numberOfPoints; i++) {
      [path addLineToPoint:self.points[i]];
    }
  } else {
    float pixelFixer = self.bounds.size.width / self.numberOfPoints;

    if (cachedNumberOfPoints != self.numberOfPoints) {
      self.points = (CGPoint *)malloc(sizeof(CGPoint) * self.numberOfPoints);
      cachedNumberOfPoints = self.numberOfPoints;

      for (int i = 0; i < self.numberOfPoints; i++) {
        self.points[i].x = i * pixelFixer;
        self.points[i].y = self.waveOffset; // self.bounds.size.height/2;
      }

      self.points[self.numberOfPoints - 1].x = self.bounds.size.width;
      self.points[0].y = self.points[self.numberOfPoints - 1].y =
          self.waveOffset; // self.bounds.size.height/2;
    }

    return [self createPathWithPoints:self.points
                           pointCount:self.numberOfPoints
                               inRect:self.bounds];
  }

  CGPathRef convertedPath = path.CGPath;

  return CGPathCreateCopy(convertedPath);
}

@end
