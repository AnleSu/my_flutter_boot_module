//
//  UCARClientSocket.m
//  UCARClientSocket
//
//  Created by  zhangfenglin on 15/9/28.
//  Copyright (c) 2015年  zhangfenglin. All rights reserved.
//

#import "UCarClientSocket.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

static int WRITE_DATA_TIMEOUT = 15;
static float DEFAULT_HEART_TIME = 10.0;

@interface UCARClientSocket () <GCDAsyncSocketDelegate>

@property (nonatomic) dispatch_queue_t delegateQueue;
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic) dispatch_source_t timer;
@property (nonatomic, strong) id<UCARClientSocketDelegate> delegate;
@property (nonatomic) BOOL activeClose;

@end

@implementation UCARClientSocket

- (instancetype)initWithDelegate:(id)aDelegate {
    return [self initWithDelegate:aDelegate
                    delegateQueue:dispatch_get_main_queue()];
}

- (instancetype)initWithDelegate:(id)aDelegate
                   delegateQueue:(dispatch_queue_t)dq {
    if (self = [super init]) {
        _delegate = aDelegate;
        _delegateQueue = dq;

        self.useAutoSendMsg = NO;
        self.writeDataTimeOut = WRITE_DATA_TIMEOUT;
        self.heartBeatTime = DEFAULT_HEART_TIME;
        _activeClose = NO;
    }
    return self;
}

- (void)createConnect {
    if (!_delegate) {
        NSLog(@"The delegate must be not nil.");
        return;
    }
    NSError *error;
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                         delegateQueue:_delegateQueue];
    //优先使用IPv6，GCDAsyncSocket在判断一个地址是否为IPv4上似乎有个bug
    //注意：当连接的地址为IP而非域名且IP为IPv4时，勿设置此值
    _socket.IPv4PreferredOverIPv6 = NO;

    if (self.needSupportIpv6IfUseIpConnectDirectly) {
        __block NSString *host = self.host;
        dispatch_async(
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
              NSError *addresseError = nil;
              NSArray *addresseArray =
                  [GCDAsyncSocket lookupHost:self.host
                                        port:self.port
                                       error:&addresseError];
              if (!addresseError) {
                  BOOL hasIpV6Host = NO;
                  BOOL hasIpV4Host = NO;

                  NSString *ipv6Addr = @"";
                  NSString *ipv4Addr = @"";

                  for (NSData *addrData in addresseArray) {
                      if ([GCDAsyncSocket isIPv6Address:addrData]) {
                          ipv6Addr = [GCDAsyncSocket hostFromAddress:addrData];
                          hasIpV6Host = YES;
                      } else if ([GCDAsyncSocket isIPv4Address:addrData]) {
                          ipv4Addr = [GCDAsyncSocket hostFromAddress:addrData];
                          hasIpV4Host = YES;
                      }
                  }

                  if (hasIpV6Host) {
                      host = ipv6Addr;
                  } else {
                      host = ipv4Addr;
                  }
              }

              dispatch_async(dispatch_get_main_queue(), ^{
                if (self.socket != nil) {
                    self.activeClose = NO;
                    [self.socket connectToHost:host
                                        onPort:self.port
                                   withTimeout:self.timeout
                                         error:nil];
                }
              });
            });
    } else {
        if (self.socket != nil) {
            self.activeClose = NO;
            [self.socket connectToHost:self.host
                                onPort:self.port
                           withTimeout:self.timeout
                                 error:&error];
        }
    }
}

- (void)makeAutoMsgTimer {
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
                                    dispatch_get_main_queue());
    dispatch_source_set_timer(
        _timer,
        dispatch_time(DISPATCH_TIME_NOW, self.heartBeatTime * NSEC_PER_SEC),
        self.heartBeatTime * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
      [self sendMessage];
    });

    dispatch_source_set_cancel_handler(_timer, ^{
      [self.socket setDelegate:nil];
      [self.socket disconnect];
      self.socket = nil;
    });
    dispatch_resume(_timer);
}

- (void)sendMessage {
    if (_delegate && [_delegate respondsToSelector:@selector(getMgsData)]) {
        NSData *data = [_delegate getMgsData];
        if (data != nil)
            [_socket writeData:data withTimeout:self.writeDataTimeOut tag:0];
    }
}

- (void)retry {
    if (!self.noNeedAutoConnect) {
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(
            DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
          [self createConnect];
        });
    }
}

- (void)writeData:(NSData *)data {
    if (data != nil && _socket != nil) {
        [_socket writeData:data withTimeout:self.writeDataTimeOut tag:0];
    }
}

- (void)disConnect {
    _activeClose = YES;
    [_socket disconnect];
    //    socket.delegate = nil;
    _socket = nil;
}

- (BOOL)isConnected {
    return _socket && _socket.isConnected;
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag {
    if (_socket) {
        [_socket readDataWithTimeout:timeout tag:tag];
    }
}

#pragma mark--gcd socket callback
- (void)socket:(GCDAsyncSocket *)sock
    didConnectToHost:(NSString *)host
                port:(uint16_t)port {
    if (_delegate && [_delegate respondsToSelector:@selector(didConnect)]) {
        [_delegate didConnect];
    }
    if (self.useAutoSendMsg)
        [self makeAutoMsgTimer];
}

- (void)socket:(GCDAsyncSocket *)sock
    didReadData:(NSData *)data
        withTag:(long)tag {
    if (_delegate && [_delegate respondsToSelector:@selector(didReadData:
                                                                 withTag:)]) {
        [_delegate didReadData:data withTag:tag];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (_delegate && [_delegate respondsToSelector:@selector(didDisConnect)]) {
        [_delegate didDisConnect];
    }
    if (_timer != nil) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    if (!_activeClose)
        [self retry];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (_delegate &&
        [_delegate respondsToSelector:@selector(didWriteDataWithTag:)]) {
        [_delegate didWriteDataWithTag:tag];
    }
}

@end
