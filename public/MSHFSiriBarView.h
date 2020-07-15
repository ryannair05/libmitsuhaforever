#import "MSHFBarView.h"
#import <UIKit/UIKit.h>

@interface MSHFSiriBarView : MSHFView

@property(nonatomic, assign) CGFloat barCornerRadius;
@property(nonatomic, assign) CGFloat barSpacing;
@property(nonatomic, strong) CALayer *redBars;
@property(nonatomic, strong) CALayer *greenBars;
@property(nonatomic, strong) CALayer *blueBars;

@end
