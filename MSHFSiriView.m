#import "public/MSHFSiriView.h"

static CGPoint midPointForPoints(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

static CGPoint controlPointForPoints(CGPoint p1, CGPoint p2) {
    CGPoint controlPoint = midPointForPoints(p1, p2);
    CGFloat diffY = fabs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
    return controlPoint;
}

@implementation MSHFSiriView

-(void)initializeWaveLayers{
    self.waveLayer = [MSHFJelloLayer layer];
    self.rWaveLayer = [MSHFJelloLayer layer];
    self.subwaveLayer = [MSHFJelloLayer layer];
    self.rSubwaveLayer = [MSHFJelloLayer layer];
    self.subSubwaveLayer = [MSHFJelloLayer layer];
    self.rSubSubwaveLayer = [MSHFJelloLayer layer];
    
    self.waveLayer.frame = self.subwaveLayer.frame = self.subSubwaveLayer.frame = self.rWaveLayer.frame = self.rSubwaveLayer.frame = self.rSubSubwaveLayer.frame = self.bounds;
    
    [self.layer addSublayer:self.waveLayer];
    [self.layer addSublayer:self.rWaveLayer];
    [self.layer addSublayer:self.subwaveLayer];
    [self.layer addSublayer:self.rSubwaveLayer];
    [self.layer addSublayer:self.subSubwaveLayer];
    [self.layer addSublayer:self.rSubSubwaveLayer];
    
    self.waveLayer.zPosition = 0;
    self.rWaveLayer.zPosition = 0;
    self.subwaveLayer.zPosition = -1;
    self.rSubwaveLayer.zPosition = -1;
    self.subSubwaveLayer.zPosition = -2;
    self.rSubSubwaveLayer.zPosition = -2;
    
    [self configureDisplayLink];
    [self resetWaveLayers];
    
    self.waveLayer.shouldAnimate = true;
    self.subwaveLayer.shouldAnimate = true;
    self.subSubwaveLayer.shouldAnimate = true;
    self.rWaveLayer.shouldAnimate = true;
    self.rSubwaveLayer.shouldAnimate = true;
    self.rSubSubwaveLayer.shouldAnimate = true;
}

-(void)resetWaveLayers{
    if (!self.waveLayer || !self.subwaveLayer || !self.subSubwaveLayer || !self.rWaveLayer || !self.rSubwaveLayer || !self.rSubSubwaveLayer) {
        [self initializeWaveLayers];
    }
    
    CGPathRef path = [self createPathWithPoints:self.points
                                     pointCount:0
                                         inRect:self.bounds];
    
    NSLog(@"[libmitsuha]: Resetting Wave Layers...");
    
    self.waveLayer.path = path;
    self.rWaveLayer.path = path;
    self.subwaveLayer.path = path;
    self.rSubwaveLayer.path = path;
    self.subSubwaveLayer.path = path;
    self.rSubSubwaveLayer.path = path;
}

-(void)updateWaveColor:(UIColor *)waveColor subwaveColor:(UIColor *)subwaveColor subSubwaveColor:(UIColor *)subSubwaveColor{
    self.waveColor = waveColor;
    self.subwaveColor = subwaveColor;
    self.subSubwaveColor = subSubwaveColor;
    self.waveLayer.fillColor = waveColor.CGColor;
    self.rWaveLayer.fillColor = waveColor.CGColor;
    self.subwaveLayer.fillColor = subwaveColor.CGColor;
    self.rSubwaveLayer.fillColor = subwaveColor.CGColor;
    self.subSubwaveLayer.fillColor = subSubwaveColor.CGColor;
    self.rSubSubwaveLayer.fillColor = subSubwaveColor.CGColor;
    self.waveLayer.compositingFilter = @"screenBlendMode";
    self.rWaveLayer.compositingFilter = @"screenBlendMode";
    self.subwaveLayer.compositingFilter = @"screenBlendMode";
    self.rSubwaveLayer.compositingFilter = @"screenBlendMode";
    self.subSubwaveLayer.compositingFilter = @"screenBlendMode";
    self.rSubSubwaveLayer.compositingFilter = @"screenBlendMode";
}

- (void)redraw{
    [super redraw];
    
    CGPathRef path = [self createPathWithPoints:self.points
                                     pointCount:self.numberOfPoints
                                         inRect:self.bounds];
    CATransform3D scale = CATransform3DMakeScale(1, -1, 1);
    CATransform3D translate = CATransform3DMakeTranslation(0, self.waveOffset - (self.bounds.size.height - self.waveOffset), 0);
    CATransform3D transform =  CATransform3DConcat(scale, translate);
    
    self.waveLayer.path = path;
    self.rWaveLayer.path = path;
    self.rWaveLayer.transform = transform;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.subwaveLayer.path = path;
        self.rSubwaveLayer.path = path;
        self.rSubwaveLayer.transform = transform;
        // CGPathRelease(path);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.subSubwaveLayer.path = path;
        self.rSubSubwaveLayer.path = path;
        self.rSubSubwaveLayer.transform = transform;
        CGPathRelease(path);
    });
}

- (void)setSampleData:(float *)data length:(int)length{
    [super setSampleData:data length:length];
    
    self.points[self.numberOfPoints - 1].x = self.bounds.size.width;
    self.points[0].y = self.points[self.numberOfPoints - 1].y = self.waveOffset;
}

- (CGPathRef)createPathWithPoints:(CGPoint *)points
                       pointCount:(NSUInteger)pointCount
                           inRect:(CGRect)rect {
    UIBezierPath *path;
    
    if (pointCount > 0){
        path = [UIBezierPath bezierPath];
        
        // [path moveToPoint:CGPointMake(0, self.frame.size.height)];
        [path moveToPoint:CGPointMake(0, self.waveOffset)];
        
        CGPoint p1 = self.points[0];
        
        [path addLineToPoint:p1];
        
        for (int i = 0; i<self.numberOfPoints; i++) {
            CGPoint p2 = self.points[i];
            CGPoint midPoint = midPointForPoints(p1, p2);
            
            [path addQuadCurveToPoint:midPoint controlPoint:controlPointForPoints(midPoint, p1)];
            [path addQuadCurveToPoint:p2 controlPoint:controlPointForPoints(midPoint, p2)];
            
            p1 = self.points[i];
        }
        
        // [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.waveOffset)];
        // [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(0, self.waveOffset)];
    }else{
        float pixelFixer = self.bounds.size.width/self.numberOfPoints;
        
        if(cachedNumberOfPoints != self.numberOfPoints){
            self.points = (CGPoint *)malloc(sizeof(CGPoint) * self.numberOfPoints);
            cachedNumberOfPoints = self.numberOfPoints;
            
            for (int i = 0; i < self.numberOfPoints; i++){
                self.points[i].x = i*pixelFixer;
                self.points[i].y = self.waveOffset; //self.bounds.size.height/2;
            }
            
            self.points[self.numberOfPoints - 1].x = self.bounds.size.width;
            self.points[0].y = self.points[self.numberOfPoints - 1].y = self.waveOffset; //self.bounds.size.height/2;
        }
        
        return [self createPathWithPoints:self.points
                               pointCount:self.numberOfPoints
                                   inRect:self.bounds];
    }
    
    CGPathRef convertedPath = path.CGPath;
    
    return CGPathCreateCopy(convertedPath);
}

@end

