#import <UIKit/UIKit.h>
#import "MSHFAudioSourceASS.h"
#import "MSHFAudioProcessingDelegate.h"
#import "MSHFAudioProcessing.h"

#define MSHFPrefsFile @"/var/mobile/Library/Preferences/com.ryannair05.mitsuhaforever.plist"

@interface MSHFView : UIView <MSHFAudioDelegate, MSHFAudioProcessingDelegate> {
  NSUInteger cachedLength;
  long long silentSince;
  bool MSHFHidden;
  float *window;
}

@property(nonatomic, assign) BOOL disableBatterySaver;
@property(nonatomic, assign) BOOL autoHide;
@property(nonatomic, assign) NSInteger numberOfPoints;
@property(nonatomic, assign) NSInteger cachedNumberOfPoints;

@property(nonatomic, assign) double gain;
@property(nonatomic, assign) double limiter;

@property(nonatomic, assign) CGFloat waveOffset;
@property(nonatomic, assign) CGFloat sensitivity;

@property(nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic, assign) CGPoint *points;

@property(nonatomic, assign) BOOL siriEnabled;

@property(nonatomic, strong) UIColor *waveColor;
@property(nonatomic, strong) UIColor *subwaveColor;
@property(nonatomic, strong) UIColor *subSubwaveColor;

@property(nonatomic, retain) MSHFAudioSource *audioSource;
@property(nonatomic, retain) MSHFAudioProcessing *audioProcessing;

- (void)updateWaveColor:(UIColor *)waveColor
           subwaveColor:(UIColor *)subwaveColor;

- (void)updateWaveColor:(UIColor *)waveColor
           subwaveColor:(UIColor *)subwaveColor
        subSubwaveColor:(UIColor *)subSubwaveColor;

- (void)start;
- (void)stop;

- (void)configureDisplayLink;

- (void)initializeWaveLayers;
- (void)resetWaveLayers;
- (void)redraw;

- (void)updateBuffer:(float *)bufferData withLength:(int)length;

- (void)setSampleData:(float *)data length:(int)length;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame
                  audioSource:(MSHFAudioSource *)audioSource;

@end

@interface BluetoothManager
+ (id)sharedInstance;
- (id)connectedDevices;
@end

@interface SBMediaController
+ (id)sharedInstance;
- (BOOL)isPlaying; 
@end
