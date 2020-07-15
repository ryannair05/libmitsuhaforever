#import "MSHFJelloLayer.h"
#import "MSHFView.h"
#import <UIKit/UIKit.h>

@interface MSHFSiriLineView : MSHFView

@property(nonatomic, assign) CGFloat lineThickness;
@property(nonatomic, strong) MSHFJelloLayer *waveLayer;
@property(nonatomic, strong) MSHFJelloLayer *subwaveLayer;
@property(nonatomic, strong) MSHFJelloLayer *subSubwaveLayer;

- (CGPathRef)createPathWithPoints:(CGPoint *)points
                       pointCount:(NSUInteger)pointCount
                           inRect:(CGRect)rect;

@end
