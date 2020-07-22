#import "MSHFView.h"

@interface MSHFBarView : MSHFView

@property(nonatomic, assign) CGFloat barCornerRadius;
@property(nonatomic, assign) CGFloat barSpacing;
@property(nonatomic, strong) CALayer *redBars;
@property(nonatomic, strong) CALayer *greenBars;
@property(nonatomic, strong) CALayer *blueBars;

@end
