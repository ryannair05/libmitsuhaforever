#import "public/MSHFAudioSourceASS.h"
#import <arpa/inet.h>
#import <sys/time.h>

const int one = 1;

@implementation MSHFAudioSourceASS

- (id)init {
  self = [super init];

  empty = (float *)malloc(sizeof(float) * 1024);
  for (int i = 0; i < 1024; i++) {
    empty[i] = 0.0f;
  }

  self.isRunning = false;

  return self;
}

- (void)start {
  NSLog(@"[libmitsuhaforever] -(void)start called");
  self->forceDisconnect = false;
  if (self.isRunning)
    return;
  self.isRunning = true;
  self->connfd = -1;
  [self.delegate updateBuffer:empty withLength:1024];
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int retries = 0;

        while (!self->forceDisconnect) {
          int r = -1;
          int rlen = 0;
          float *data = NULL;
          UInt32 len = sizeof(float);

          NSLog(@"[libmitsuhaforever] Connecting to mediaserverd.");
          retries++;
          self->connfd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

          if (self->connfd == -1) {
            usleep(1000 * 1000);
            NSLog(@"[libmitsuhaforever] Connection failed.");
            continue;
          }

          struct timeval tv;
          tv.tv_sec = 0;
          tv.tv_usec = 50000;
          setsockopt(self->connfd, SOL_SOCKET, SO_RCVTIMEO, (const char *)&tv,
                     sizeof tv);
          setsockopt(self->connfd, SOL_SOCKET, SO_SNDTIMEO, (const char *)&tv,
                     sizeof tv);
          setsockopt(self->connfd, SOL_SOCKET, SO_NOSIGPIPE, &one, sizeof(one));

          struct sockaddr_in remote;
          memset(&remote, 0, sizeof(struct sockaddr_in));
          remote.sin_family = PF_INET;
          remote.sin_port = htons(ASSPort);
          inet_aton("127.0.0.1", &remote.sin_addr);

          int cretries = 0;
          while (r != 0 && cretries < 5) {
            cretries++;
            r = connect(self->connfd, (struct sockaddr *)&remote, sizeof(remote));
            usleep(200 * 1000);
          }

          if (r != 0) {
            NSLog(@"[libmitsuhaforever] Connection failed.");
            retries++;
            usleep(1000 * 1000);
            continue;
          }

          if (retries > 5) {
            self->forceDisconnect = true;
            NSLog(@"[libmitsuhaforever] Too many retries. Aborting.");
            break;
          }

          retries = 0;
          NSLog(@"[libmitsuhaforever] Connected.");

          fd_set readset;
          int result = -1;
          FD_ZERO(&readset);
          FD_SET(self->connfd, &readset);

          while (!self->forceDisconnect) {
            if (self->connfd < 0)
              break;
            result = select(self->connfd + 1, &readset, NULL, NULL, &tv);

            if (result < 0) {
              close(self->connfd);
              break;
            }

            rlen = recv(self->connfd, &len, sizeof(UInt32), 0);

            if (self->connfd < 0)
              break;

            if (rlen < sizeof(UInt32)) {
              close(self->connfd);
              self->connfd = -1;
              break;
            }

            if (len > 8192 || len < 0) {
              close(self->connfd);
              break;
            }

            if (len > sizeof(float)) {
              free(data);
              data = (float *)malloc(len);
              rlen = recv(self->connfd, data, len, 0);

              if (self->connfd < 0)
                break;

              if (rlen > 0) {
                retries = 0;
                if (self.delegate) {
                  [self.delegate updateBuffer:data
                                   withLength:rlen / sizeof(float)];
                } else {
                  close(self->connfd);
                  self->connfd = -1;
                }
              } else {
                if (rlen == 0)
                  close(self->connfd);
                self->connfd = -1;
                len = sizeof(float);
                data = self->empty;
              }
            }

            usleep(16 * 1000);
            rlen = send(self->connfd, &one, sizeof(int), 0);
            if (rlen <= 0) {
              close(self->connfd);
              self->connfd = -1;
              break;
            }
          }

          if (self->forceDisconnect) {
            NSLog(@"[libmitsuhaforever] Forcefully disconnected.");
            close(self->connfd);
            self->connfd = -1;
            break;
          }

          NSLog(@"[libmitsuhaforever] Lost connection.");
          usleep(1000 * 1000);
        }

        self.isRunning = false;

        NSLog(@"[libmitsuhaforever] Finally disconnected.");
      });
}

-(void)dealloc {
    free(empty);
}

- (void)stop {
  NSLog(@"[libmitsuhaforever] -(void)stop called");
  self->forceDisconnect = true;
}

@end
