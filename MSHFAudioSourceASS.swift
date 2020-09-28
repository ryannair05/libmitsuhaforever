import Foundation

let ASSPort:UInt16 = 44333
var one = 1

func FD_SET(fd: Int32, set: inout fd_set) {
    let intOffset = Int(fd / 32)
    let bitOffset = fd % 32
    let mask: Int32 = 1 << bitOffset
    switch intOffset {
        case 0: set.fds_bits.0 = set.fds_bits.0 | mask
        case 1: set.fds_bits.1 = set.fds_bits.1 | mask
        case 2: set.fds_bits.2 = set.fds_bits.2 | mask
        case 3: set.fds_bits.3 = set.fds_bits.3 | mask
        case 4: set.fds_bits.4 = set.fds_bits.4 | mask
        case 5: set.fds_bits.5 = set.fds_bits.5 | mask
        case 6: set.fds_bits.6 = set.fds_bits.6 | mask
        case 7: set.fds_bits.7 = set.fds_bits.7 | mask
        case 8: set.fds_bits.8 = set.fds_bits.8 | mask
        case 9: set.fds_bits.9 = set.fds_bits.9 | mask
        case 10: set.fds_bits.10 = set.fds_bits.10 | mask
        case 11: set.fds_bits.11 = set.fds_bits.11 | mask
        case 12: set.fds_bits.12 = set.fds_bits.12 | mask
        case 13: set.fds_bits.13 = set.fds_bits.13 | mask
        case 14: set.fds_bits.14 = set.fds_bits.14 | mask
        case 15: set.fds_bits.15 = set.fds_bits.15 | mask
        case 16: set.fds_bits.16 = set.fds_bits.16 | mask
        case 17: set.fds_bits.17 = set.fds_bits.17 | mask
        case 18: set.fds_bits.18 = set.fds_bits.18 | mask
        case 19: set.fds_bits.19 = set.fds_bits.19 | mask
        case 20: set.fds_bits.20 = set.fds_bits.20 | mask
        case 21: set.fds_bits.21 = set.fds_bits.21 | mask
        case 22: set.fds_bits.22 = set.fds_bits.22 | mask
        case 23: set.fds_bits.23 = set.fds_bits.23 | mask
        case 24: set.fds_bits.24 = set.fds_bits.24 | mask
        case 25: set.fds_bits.25 = set.fds_bits.25 | mask
        case 26: set.fds_bits.26 = set.fds_bits.26 | mask
        case 27: set.fds_bits.27 = set.fds_bits.27 | mask
        case 28: set.fds_bits.28 = set.fds_bits.28 | mask
        case 29: set.fds_bits.29 = set.fds_bits.29 | mask
        case 30: set.fds_bits.30 = set.fds_bits.30 | mask
        case 31: set.fds_bits.31 = set.fds_bits.31 | mask
        default: break
    }
}

class MSHFAudioSourceASS: MSHFAudioSource {

  var connfd: Int32 = 0
  var empty: UnsafeMutablePointer<Float>!
  var forceDisconnect = false

  override init() {
      super.init()

      empty = unsafeBitCast(malloc(MemoryLayout<Float>.size * 1024), to: UnsafeMutablePointer<Float>.self)
      for i in 0..<1024 {
          empty[i] = 0.0
      }

      isRunning = false
  }

  deinit {
      free(empty)
  }

  override func start() {

      NSLog("[libmitsuhaforever] -(void)start called")
      forceDisconnect = false
      if isRunning {
          return
      }
      isRunning = true
      delegate?.updateBuffer(empty, withLength: 1024)
      DispatchQueue.global(qos: .default).async(
          execute: { [self] in

        var retries = 0

        while !forceDisconnect {
            var r = -1
            var rlen = 0
            var data: UnsafeMutablePointer<Float>? = nil
            var len = UInt32(MemoryLayout<Float>.size)

            NSLog("[libmitsuhaforever] Connecting to mediaserverd.")
            retries += 1
            connfd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)

            if connfd == -1 {
                usleep(1000 * 1000)
                NSLog("[libmitsuhaforever] Connection failed.")
                continue
            }

            var tv: timeval = timeval()
            tv.tv_sec = 0
            tv.tv_usec = 50000
            setsockopt(connfd, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout.size(ofValue: tv)))
            setsockopt(connfd, SOL_SOCKET, SO_SNDTIMEO, &tv, socklen_t(MemoryLayout.size(ofValue: tv)))
            setsockopt(connfd, SOL_SOCKET, SO_NOSIGPIPE, &one, socklen_t(MemoryLayout.size(ofValue: one)))

            var remote: sockaddr_in = sockaddr_in()
            // memset(&remote, 0,  MemoryLayout<sockaddr_in>.size)
            remote.sin_family = sa_family_t(PF_INET)
            remote.sin_port = CFSwapInt16(ASSPort);
            inet_aton("127.0.0.1", &remote.sin_addr)
            var cretries = 0
 
            while r != 0 && cretries < 5 {
                cretries += 1
                let remote2 = remote
                withUnsafePointer(to: &remote) {sockaddrInPtr in
                    let sockaddrPtr = UnsafeRawPointer(sockaddrInPtr).assumingMemoryBound(to: sockaddr.self)
                    r = Int(connect(connfd, sockaddrPtr, socklen_t(MemoryLayout.size(ofValue: remote2))))
                }
                usleep(200 * 1000)
            }

            if r != 0 {
                NSLog("[libmitsuhaforever] Connection failed.")
                retries += 1
                usleep(1000 * 1000)
                continue
            }
            
            if retries > 5 {
                forceDisconnect = true
                NSLog("[libmitsuhaforever] Too many retries. Aborting.")
                break
            }

            retries = 0

            var readset: fd_set = fd_set()
            var result: Int32 = -1
            readset.fds_bits = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            FD_SET(fd: connfd, set: &readset)
          

            while !forceDisconnect {

                if connfd < 0 {
                    break
                }

                result = select(connfd + 1, &readset, nil, nil, &tv)

                if result < 0 {
                    close(connfd)
                    break
                }

                rlen = recv(self.connfd, &len, MemoryLayout<UInt32>.size, 0)


                // if rlen < MemoryLayout<UInt32>.size {
                //     close(self.connfd)
                //     self.connfd = -1
                //     break
                // }


                if len > 8192 || len < 0 {
                    close(connfd)
                    break
                }

                if len > MemoryLayout<Float>.size {
                    free(data)
                    data = unsafeBitCast(malloc(Int(len)), to: UnsafeMutablePointer<Float>.self)
                    rlen = recv(connfd, data, Int(len), 0)

                    if rlen > 0 {
                        if delegate != nil {
                            delegate!.updateBuffer(
                                data!,
                                withLength: rlen / MemoryLayout<Float>.size)
                        } else {
                            close(connfd)
                            connfd = -1
                        }
                    } else {
                        if rlen == 0 {
                            close(connfd)
                        }
                        connfd = -1
                        len = UInt32(MemoryLayout<Float>.size)
                        data = empty
                    }
                }

                usleep(16 * 1000)
                rlen = send(connfd, &one, MemoryLayout<Int>.size, 0)
                if rlen <= 0 {
                    close(connfd)
                    connfd = -1
                    break
                }
            }

            if forceDisconnect {
                NSLog("[libmitsuhaforever] Forcefully disconnected.")
                close(connfd)
                connfd = -1
                break
            }

            NSLog("[libmitsuhaforever] Lost connection.")
            usleep(1000 * 1000)
        }
        isRunning = false

        NSLog("[libmitsuhaforever] Finally disconnected.")
    })
  }

  override func stop() {
      print("[libmitsuhaforever] -(void)stop called")
      forceDisconnect = true
  }
}
