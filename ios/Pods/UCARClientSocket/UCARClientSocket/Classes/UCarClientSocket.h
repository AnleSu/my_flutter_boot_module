//
//  UCARClientSocket.h
//  UCARClientSocket
//
//  Created by  zhangfenglin on 15/9/28.
//  Copyright (c) 2015年  zhangfenglin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UCARClientSocketDelegate <NSObject>

@optional
- (NSData *)getMgsData;
- (void)didReadData:(NSData *)data withTag:(long)tag;
- (void)didWriteDataWithTag:(long)tag;
- (void)didConnect;
- (void)didDisConnect;
@end

@class GCDAsyncSocket;
@interface UCARClientSocket : NSObject

@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) UInt16 port;
@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, assign) NSTimeInterval writeDataTimeOut;
@property (nonatomic, assign) BOOL useAutoSendMsg;
@property (nonatomic, assign) float heartBeatTime;
@property (nonatomic, assign) BOOL needSupportIpv6IfUseIpConnectDirectly;
@property (nonatomic, assign) BOOL noNeedAutoConnect;

- (instancetype)initWithDelegate:(id)aDelegate
                   delegateQueue:(dispatch_queue_t)dq;
- (instancetype)initWithDelegate:(id)aDelegate;

- (void)createConnect;
- (void)writeData:(NSData *)data;
- (void)disConnect;
- (BOOL)isConnected;
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;
@end
