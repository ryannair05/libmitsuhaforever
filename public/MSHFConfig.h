#import "MSHFBarView.h"
#import "MSHFDotView.h"
#import "MSHFJelloView.h"
#import "MSHFLineView.h"
#import "MSHFSiriView.h"
#import "MSHFView.h"

@interface MSHFConfig : NSObject

@property BOOL enabled;
@property(nonatomic, assign) NSString *application;

@property int style;
@property int colorMode;
@property BOOL enableDynamicGain;
@property BOOL enableAutoUIColor;
@property BOOL enableFFT;
@property BOOL enableCoverArtBugFix;
@property BOOL disableBatterySaver;
@property BOOL enableAutoHide;
@property double gain;
@property double limiter;

@property(nonatomic, strong) UIColor *waveColor;
@property(nonatomic, strong) UIColor *subwaveColor;
@property(nonatomic, strong) UIColor *subSubwaveColor;
@property(nonatomic, strong) UIColor *calculatedColor;

@property NSUInteger numberOfPoints;
@property CGFloat fps;

@property CGFloat waveOffset;
@property CGFloat waveOffsetOffset;
@property CGFloat sensitivity;
@property CGFloat dynamicColorAlpha;

@property CGFloat barSpacing;
@property CGFloat barCornerRadius;
@property CGFloat lineThickness;

@property BOOL ignoreColorFlow;

@property BOOL enableCircleArtwork;

@property(nonatomic, retain) MSHFView *view;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (MSHFConfig *)loadConfigForApplication:(NSString *)name;
- (UIColor *)getAverageColorFrom:(UIImage *)image withAlpha:(double)alpha;
- (void)colorizeView:(UIImage *)image;
- (void)initializeViewWithFrame:(CGRect)frame;
+ (NSDictionary *)parseConfigForApplication:(NSString *)name;
- (void)setDictionary:(NSDictionary *)dict;
- (void)configureView;
- (void)reloadConfig;

@end
