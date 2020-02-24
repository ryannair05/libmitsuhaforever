@protocol MSHFFAudioDelegate <NSObject>

- (void)updateBuffer:(float *)bufferData withLength:(int)length;

@end