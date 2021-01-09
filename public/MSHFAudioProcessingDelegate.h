//
//  MSHFAudioProcessingDelegate.h
//  libmitsuhaforever
//
//

#import <Foundation/Foundation.h>

@protocol MSHFAudioProcessingDelegate <NSObject>

- (void)setSampleData:(float *)data length:(int)length;

@end
