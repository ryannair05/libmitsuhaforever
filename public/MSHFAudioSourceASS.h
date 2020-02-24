#import "MSHFFAudioSource.h"

#define ASSPort 44333

@interface MSHFAudioSourceASS : MSHFAudioSource {
  int connfd;
  float *empty;
  bool forceDisconnect;
}

@end