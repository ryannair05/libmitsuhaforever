#import "MSHFView.h"
#import "MSHFJelloLayer.h"

@interface MSHFSiriView : MSHFView

@property(nonatomic, strong) MSHFJelloLayer *waveLayer;
@property(nonatomic, strong) MSHFJelloLayer *rWaveLayer;
@property(nonatomic, strong) MSHFJelloLayer *subwaveLayer;
@property(nonatomic, strong) MSHFJelloLayer *rSubwaveLayer;
@property(nonatomic, strong) MSHFJelloLayer *subSubwaveLayer;
@property(nonatomic, strong) MSHFJelloLayer *rSubSubwaveLayer;

-(CGPathRef)createPathWithPoints:(CGPoint *)points pointCount:(NSUInteger)pointCount inRect:(CGRect)rect;

@end