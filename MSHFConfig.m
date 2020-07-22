#import "public/MSHFConfig.h"
#import "public/MSHFUtils.h"
#import <libcolorpicker.h>

@interface DarwinNotificationsManager : NSObject

@property (strong, nonatomic) id someProperty;

+ (instancetype)sharedInstance;

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(void))callback;
- (void)postNotificationWithName:(NSString *)name;

@end

@implementation MSHFConfig

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self) {
    [self setDictionary:dict];
    [[DarwinNotificationsManager sharedInstance] registerForNotificationName:MSHFPreferencesChanged callback:^() {
      [self reloadConfig];
    }];
  }
  return self;
}

- (void)initializeViewWithFrame:(CGRect)frame {
  UIView *superview = nil;
  NSUInteger index;

  if (_view) {
    if ([_view superview]) {
      superview = [_view superview];
      index = [superview.subviews indexOfObject:_view];
    }

    [_view stop];
    [_view removeFromSuperview];
  }

  switch (_style) {
  case 1:
    self.view = [[MSHFBarView alloc] initWithFrame:frame];
    [((MSHFBarView *)_view) setBarSpacing:self.barSpacing];
    [((MSHFBarView *)_view) setBarCornerRadius:self.barCornerRadius];
    break;
  case 2:
    self.view = [[MSHFLineView alloc] initWithFrame:frame];
    [((MSHFLineView *)_view) setLineThickness:self.lineThickness];
    break;
  case 3:
    self.view = [[MSHFDotView alloc] initWithFrame:frame];
    [((MSHFDotView *)_view) setBarSpacing:self.barSpacing];
    break;
  case 4:
    self.view = [[MSHFSiriView alloc] initWithFrame:frame];
    break;
  default:
    self.view = [[MSHFJelloView alloc] initWithFrame:frame];
  }

  if (superview) {
    if (index == NSNotFound) {
      [superview addSubview:_view];
    } else {
      [superview insertSubview:_view atIndex:index];
    }
  }

  [self configureView];
}

- (void)configureView {
  _view.autoHide = self.enableAutoHide;
  _view.displayLink.preferredFramesPerSecond = self.fps;
  _view.numberOfPoints = self.numberOfPoints;
  _view.waveOffset = self.waveOffset + self.waveOffsetOffset;
  _view.gain = self.gain;
  _view.limiter = self.limiter;
  _view.sensitivity = self.sensitivity;
  _view.audioProcessing.fft = self.enableFFT;
  _view.disableBatterySaver = self.disableBatterySaver;
  NSLog(@"[Mitsuha] self.waveColor: %@", self.waveColor);
  NSLog(@"[Mitsuha] self.subwaveColor: %@", self.subwaveColor);
  NSLog(@"[Mitsuha] self.subSubwaveColor: %@", self.subSubwaveColor);
  NSLog(@"[Mitsuha] self.colorMode: %d", self.colorMode);
  
  _view.siriEnabled = self.colorMode == 1;

  if (self.colorMode == 2 && self.waveColor) {
    if (self.style == 4) {
      [_view updateWaveColor:[self.waveColor copy]
                subwaveColor:[self.waveColor copy]
             subSubwaveColor:[self.waveColor copy]];
    } else {
      [_view updateWaveColor:[self.waveColor copy]
                subwaveColor:[self.waveColor copy]];
    }
  } else if (self.colorMode == 1 && self.waveColor && self.subwaveColor && self.subSubwaveColor) {
    [_view updateWaveColor:[self.waveColor copy]
              subwaveColor:[self.subwaveColor copy]
           subSubwaveColor:[self.subSubwaveColor copy]];
  } else if (self.calculatedColor) {
    [_view updateWaveColor:[self.calculatedColor copy]
              subwaveColor:[self.calculatedColor copy]];
  }
}
- (UIColor *)getAverageColorFrom:(UIImage *)image withAlpha:(double)alpha {
  CGSize size = {1, 1};
  UIGraphicsBeginImageContext(size);
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);

  [image drawInRect:(CGRect){.size = size} blendMode:kCGBlendModeCopy alpha:1];

  uint8_t *data = (uint8_t *)CGBitmapContextGetData(ctx);

  UIColor *color = [UIColor colorWithRed:data[2] / 255.0f
                                   green:data[1] / 255.0f
                                    blue:data[0] / 255.0f
                                   alpha:alpha];

  UIGraphicsEndImageContext();
  return color;
}
- (void)colorizeView:(UIImage *)image {
  if (self.view == NULL)
    return;
  UIColor *color = self.waveColor;
  if (self.colorMode != 2) {
    
    UIColor *scolor = self.waveColor;
    UIColor *sscolor = self.waveColor;
    
    if (self.colorMode == 1) {
      color = [UIColor colorWithRed:1.0f
                              green:0.0f
                              blue:0.0f
                              alpha:self.dynamicColorAlpha];
      scolor = [UIColor colorWithRed:0.0f
                              green:1.0f
                                blue:0.0f
                              alpha:self.dynamicColorAlpha];
      sscolor = [UIColor colorWithRed:0.0f
                                green:0.0f
                                blue:1.0f
                                alpha:self.dynamicColorAlpha];
    } else {
      color = [self getAverageColorFrom:image
                              withAlpha:self.dynamicColorAlpha];
      self.calculatedColor = color;
    }
    
    if (self.colorMode == 1) {
      [self.view updateWaveColor:[color copy]
                    subwaveColor:[scolor copy]
                subSubwaveColor:[sscolor copy]];
    } else if (self.colorMode != 1 && self.style == 4) {
      [self.view updateWaveColor:[color copy]
                    subwaveColor:[color copy]
                subSubwaveColor:[color copy]];
    }  else {
      [self.view updateWaveColor:[color copy]
                    subwaveColor:[color copy]];
    }
  } else {
    if (self.style == 4) {
      [_view updateWaveColor:[color copy]
                subwaveColor:[color copy]
             subSubwaveColor:[color copy]];
    } else {
      [_view updateWaveColor:[color copy]
                subwaveColor:[color copy]];
    }
  }
}

- (void)setDictionary:(NSDictionary *)dict {
  _application = [dict objectForKey:@"application"];
  _enabled = [([dict objectForKey:@"enabled"] ?: @(YES)) boolValue];

  _enableDynamicGain =
      [([dict objectForKey:@"enableDynamicGain"] ?: @(NO)) boolValue];
  _style = [([dict objectForKey:@"style"] ?: @(0)) intValue];
  _colorMode = [([dict objectForKey:@"colorMode"] ?: @(0)) intValue];
  _enableAutoUIColor =
      [([dict objectForKey:@"enableAutoUIColor"] ?: @(YES)) boolValue];
  _ignoreColorFlow =
      [([dict objectForKey:@"ignoreColorFlow"] ?: @(NO)) boolValue];
  _enableCircleArtwork =
      [([dict objectForKey:@"enableCircleArtwork"] ?: @(NO)) boolValue];
  _enableCoverArtBugFix =
      [([dict objectForKey:@"enableCoverArtBugFix"] ?: @(NO)) boolValue];
  _disableBatterySaver =
      [([dict objectForKey:@"disableBatterySaver"] ?: @(NO)) boolValue];
  _enableFFT = [([dict objectForKey:@"enableFFT"] ?: @(NO)) boolValue];
  _enableAutoHide =
      [([dict objectForKey:@"enableAutoHide"] ?: @(YES)) boolValue];

  if ([dict objectForKey:@"waveColor"]) {
    if ([[dict objectForKey:@"waveColor"] isKindOfClass:[UIColor class]]) {
      _waveColor = [dict objectForKey:@"waveColor"];
    } else if ([[dict objectForKey:@"waveColor"]
                   isKindOfClass:[NSString class]]) {
      _waveColor =
          LCPParseColorString([dict objectForKey:@"waveColor"], @"#000000:0.5");
    } else {
      _waveColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
  } else {
    _waveColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
  }

  if ([dict objectForKey:@"subwaveColor"]) {
    if ([[dict objectForKey:@"subwaveColor"] isKindOfClass:[UIColor class]]) {
      _subwaveColor = [dict objectForKey:@"subwaveColor"];
    } else if ([[dict objectForKey:@"subwaveColor"]
                   isKindOfClass:[NSString class]]) {
      _subwaveColor = LCPParseColorString([dict objectForKey:@"subwaveColor"],
                                          @"#000000:0.5");
    } else {
      _subwaveColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
  } else {
    _subwaveColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
  }
  
  if ([dict objectForKey:@"subSubwaveColor"]) {
    if ([[dict objectForKey:@"subSubwaveColor"] isKindOfClass:[UIColor class]]) {
      _subwaveColor = [dict objectForKey:@"subSubwaveColor"];
    } else if ([[dict objectForKey:@"subSubwaveColor"]
                   isKindOfClass:[NSString class]]) {
      _subwaveColor = LCPParseColorString([dict objectForKey:@"subSubwaveColor"],
                                          @"#000000:0.5");
    } else {
      _subwaveColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
  } else {
    _subwaveColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
  }

  _gain = [([dict objectForKey:@"gain"] ?: @(50)) doubleValue];
  _limiter = [([dict objectForKey:@"limiter"] ?: @(0)) doubleValue];
  _numberOfPoints =
      [([dict objectForKey:@"numberOfPoints"] ?: @(8)) unsignedIntegerValue];
  _sensitivity = [([dict objectForKey:@"sensitivity"] ?: @(1)) doubleValue];
  _dynamicColorAlpha =
      [([dict objectForKey:@"dynamicColorAlpha"] ?: @(0.6)) doubleValue];

  _barSpacing = [([dict objectForKey:@"barSpacing"] ?: @(5)) doubleValue];
  _barCornerRadius =
      [([dict objectForKey:@"barCornerRadius"] ?: @(0)) doubleValue];
  _lineThickness = [([dict objectForKey:@"lineThickness"] ?: @(5)) doubleValue];

  _waveOffset = [([dict objectForKey:@"waveOffset"] ?: @(0)) doubleValue];
  _waveOffset = ([([dict objectForKey:@"negateOffset"] ?: @(false)) boolValue]
                     ? _waveOffset * -1
                     : _waveOffset);

  _fps = [([dict objectForKey:@"fps"] ?: @(24)) doubleValue];
}

+ (NSDictionary *)parseConfigForApplication:(NSString *)name {
  NSMutableDictionary *prefs = [@{} mutableCopy];
  [prefs setValue:name forKey:@"application"];

  NSDictionary *file =
      [[NSDictionary alloc] initWithContentsOfFile:MSHFPrefsFile];

  for (NSString *key in [file allKeys]) {
    [prefs setValue:[file objectForKey:key] forKey:key];
  }

  for (NSString *key in [prefs allKeys]) {
    NSString *removedKey = [key stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"MSHF%@", name] withString:@""];
    NSString *lowerCaseKey = [NSString stringWithFormat:@"%@%@",[[removedKey substringToIndex:1] lowercaseString], [removedKey substringFromIndex:1]];

    [prefs setValue:[prefs objectForKey:key] forKey:lowerCaseKey];
  }

  prefs[@"gain"] = [prefs objectForKey:@"gain"] ?: @(50);
  prefs[@"subwaveColor"] = prefs[@"waveColor"];
  prefs[@"subSubwaveColor"] = prefs[@"waveColor"];
  prefs[@"waveOffset"] = ([prefs objectForKey:@"waveOffset"] ?: @(0));

  return prefs;
}

- (void)reloadConfig {
  int oldStyle = self.style;
  [self setDictionary:[MSHFConfig parseConfigForApplication:self.application]];
  if (self.view) {
    if (self.style != oldStyle) {
      [self initializeViewWithFrame:self.view.frame];
      [[self view] start];
    } else {
      [self configureView];
    }
  }
}

+ (MSHFConfig *)loadConfigForApplication:(NSString *)name {
  return [[MSHFConfig alloc]
      initWithDictionary:[MSHFConfig parseConfigForApplication:name]];
}

@end

@implementation DarwinNotificationsManager {
    NSMutableDictionary * handlers;
}

+ (instancetype)sharedInstance {
    static id instance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        handlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(void))callback {
    handlers[name] = callback;
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(center, (__bridge const void *)(self), defaultNotificationCallback, (__bridge CFStringRef)name, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)postNotificationWithName:(NSString *)name {
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(center, (__bridge CFStringRef)name, NULL, NULL, YES);
}

- (void)notificationCallbackReceivedWithName:(NSString *)name {
    void (^callback)(void) = handlers[name];
    callback();
}

void defaultNotificationCallback (CFNotificationCenterRef center,
                 void *observer,
                 CFStringRef name,
                 const void *object,
                 CFDictionaryRef userInfo)
{
    NSLog(@"name: %@", name);
    NSLog(@"userinfo: %@", userInfo);

    NSString *identifier = (__bridge NSString *)name;
    [[DarwinNotificationsManager sharedInstance] notificationCallbackReceivedWithName:identifier];
}


- (void)dealloc {
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterRemoveEveryObserver(center, (__bridge const void *)(self));
}


@end
