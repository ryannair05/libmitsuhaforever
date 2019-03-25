#import <arpa/inet.h>
#import "public/MSHAudioSourceASS.h"

const int one = 1;

@implementation MSHAudioSourceASS

-(id)init {
    self = [super init];

    empty = (float *)malloc(sizeof(float));
    empty[0] = 0.0f;

    return self;
}

-(void)start {
    connfd = -1;
    [self.delegate updateBuffer:empty withLength:1];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"[MitsuhaInfinity] connfd = %d", connfd);
        struct sockaddr_in remote;
        remote.sin_family = PF_INET;
        remote.sin_port = htons(ASSPort);
        inet_aton("127.0.0.1", &remote.sin_addr);
        int r = -1;
        int rlen = 0;
        float *data = NULL;
        UInt32 len = sizeof(float);
        int retries = 0;

        while (connfd != -2) {
            NSLog(@"[MitsuhaInfinity] Connecting to mediaserverd.");
            retries++;
            connfd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

            if (connfd == -1) {
                usleep(1000 * 1000);
                continue;
            }
            setsockopt(connfd, SOL_SOCKET, SO_NOSIGPIPE, &one, sizeof(one));

            while(r != 0) {
                r = connect(connfd, (struct sockaddr *)&remote, sizeof(remote));
                usleep(200 * 1000);
            }

            NSLog(@"[MitsuhaInfinity] Connected.");

            if (retries > 10) {
                connfd = -2;
                NSLog(@"[MitsuhaInfinity] Too many retries. Aborting.");
                break;
            }

            while(true) {
                if (connfd < 0) break;

                rlen = recv(connfd, &len, sizeof(UInt32), 0);

                if (connfd < 0) break;

                if (rlen <= 0) {
                    if (rlen == 0) close(connfd);
                    connfd = -1;
                    len = sizeof(float);
                    data = empty;
                }

                if (len > sizeof(float)) {
                    free(data);
                    data = (float *)malloc(len);
                    rlen = recv(connfd, data, len, 0);

                    if (connfd < 0) break;

                    if (rlen > 0) {
                        retries = 0;
                        if (self.delegate) {
                            [self.delegate updateBuffer:data withLength:rlen/sizeof(float)];
                        }
                    } else {
                        if (rlen == 0) close(connfd);
                        connfd = -1;
                        len = sizeof(float);
                        data = empty;
                    }
                }
            }

            if (connfd == -2) break;
            usleep(1000 * 1000);
        }
        
        NSLog(@"[MitsuhaInfinity] Forcefully disconnected.");
    });
}

-(void)stop {
    NSLog(@"[MitsuhaInfinity] Disconnect");
    close(connfd);
    connfd = -2;
}

-(void)requestUpdate {
    if (connfd > 0) {
        int slen = send(connfd, &one, sizeof(int), 0);
        if (slen <= 0) {
            if (slen == 0) {
                close(connfd);
            }
            connfd = -1;
        }
    }
}

@end