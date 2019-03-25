#import "MSHAudioDelegate.h"

@interface MSHAudioSource : NSObject

@property (nonatomic, assign, readonly) bool isRunning;
@property (nonatomic, retain) id<MSHAudioDelegate> delegate;

-(id)init;
-(void)start;
-(void)stop;
-(void)requestUpdate;

@end