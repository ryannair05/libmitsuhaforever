@protocol MSHFFAudioProcessingDelegate <NSObject>

- (void)setSampleData:(float *)data length:(int)length;

@end