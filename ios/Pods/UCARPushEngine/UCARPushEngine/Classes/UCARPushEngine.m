//
//  UCARPushEngine.m
//  UCARPushDemo
//
//  Created by North on 10/27/16.
//  Copyright © 2016 North. All rights reserved.
//

#import "UCARPushEngine.h"
#import "UCARPushKey.h"
#import "UCARSocketPacket.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <UCARMonitor/UCARMonitorStore.h>
#import <UCARNetwork/UCARNetwork.h>
#import <UCARUtility/UCARUtility.h>
#import <UCARUtility/UCARWeakProxy.h>

NSString *const UCARNetManagerSubURL = @"/ucarnetmanager/hostmanage/getnetinfo";
const int UCARPushUUIDCacheCount = 100;
NSString *const UCARPushUUIDCacheKey = @"UCARPushUUIDCacheKey";

@interface UCARPushIPModel : NSObject

@property (nonatomic) NSString *host;
@property (nonatomic) uint16_t port;

@end

@implementation UCARPushIPModel

@end

@interface UCARPushEngine () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
//缓存近20条消息的uuid
@property (nonatomic) NSMutableArray<NSString *> *packetUUIDPool;

@property (nonatomic) NSString *secretKey;
@property (nonatomic) NSArray<UCARPushIPModel *> *ports;
@property (nonatomic) NSInteger currentIPIndex;
//重连计数
@property (nonatomic) NSInteger reconnectCounter;

@property (nonatomic) NSTimeInterval heartbeatTime;
@property (nonatomic) NSTimer *heartbeatTimer;

@property (nonatomic) BOOL engineRunning;

@property (nonatomic) NSMutableData *packetData;

@end

@implementation UCARPushEngine

- (void)setHeartbeatTime:(NSTimeInterval)heartbeatTime {
    _heartbeatTime = heartbeatTime;
    [self resetHeartbeatTimer];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *UUIDs = [[NSUserDefaults standardUserDefaults] valueForKey:UCARPushUUIDCacheKey];
        if (UUIDs) {
            _packetUUIDPool = [UUIDs mutableCopy];
        } else {
            _packetUUIDPool = [NSMutableArray arrayWithCapacity:UCARPushUUIDCacheCount];
        }

        _engineRunning = NO;

        _reconnectTimes = 20;
        _reconnectCounter = 0;

        _heartbeatTime = 10.0;

        //避免断包解析复杂化，回调必须在串行队列中执行
        //严禁设置回调线程为并发线程
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

        _packetData = [NSMutableData data];
    }
    return self;
}

//================================
- (void)resetHeartbeatTimer {
    [self stopHeartbeatTimer];

    UCARWeakProxy *proxy = [UCARWeakProxy proxyWithTarget:self];
    _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:_heartbeatTime
                                                       target:proxy
                                                     selector:@selector(heartbeat)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)stopHeartbeatTimer {
    [_heartbeatTimer invalidate];
    _heartbeatTimer = nil;
}

- (void)heartbeat {
    if (_socket.isConnected) {
        UCARSocketPacket *packet = [UCARSocketPacket socketPacketWithMessageType:UCARSocketMessageType_HEARTBEAT_REQ];
        NSData *data = [packet encryptedDataWithEncryptKey:nil];
        [self sendData:data];
    }
}
//============================

- (void)startEngine {
    _engineRunning = YES;
    //判断是否存在数据，防止重复请求
    if (_ports.count > 0) {
        [self connectServer];
    } else {
        [self refreshIP];
    }
}

- (void)stopEngine {
    _engineRunning = NO;
    [self stopHeartbeatTimer];
    [_socket disconnect];
}

- (void)connectServer {
    UCARLoggerInfo(@"UCARPush connectServer IPIndex %@, reconnectTimes %@", @(_currentIPIndex), @(_reconnectCounter));
    if (_reconnectCounter == _reconnectTimes) {
        [self refreshIP];
        return;
    }

    [self resetHeartbeatTimer];
    _packetData = [NSMutableData data];

    UCARPushIPModel *currentIP = _ports[_currentIPIndex];
    [_socket connectToHost:currentIP.host onPort:currentIP.port error:nil];

    _reconnectCounter++;
    _currentIPIndex++;
    if (_currentIPIndex == _ports.count) {
        _currentIPIndex = 0;
    }
}

- (void)refreshIP {
    //文档链接：
    // 1. http://wiki.10101111.com/pages/viewpage.action?pageId=15532553
    // 2. http://wiki.10101111.com/pages/viewpage.action?pageId=32736036
    NSString *sdkVersion = @(UCARPushSDKVersion).stringValue;
    NSDictionary *parameters = @{@"dt" : _deviceID, @"appv" : _appVersion, @"sdkv" : sdkVersion, @"sys" : _sysName};
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *encryptText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    encryptText = [NSString AESForEncry:encryptText WithKey:ucar_wtfpush()];
    NSDictionary *param = @{@"param" : encryptText};
    NSDictionary *header = @{@"cversion" : sdkVersion, @"d" : _deviceID};
    UCARHttpBaseConfig *config = [UCARHttpBaseConfig defaultConfig];
    config.domain = _netManagerHost;
    config.subURL = UCARNetManagerSubURL;
    config.parameters = param;
    config.header = header;
    config.httpMethod = UCARHttpMethodGet;
    config.needDecrypt = YES;
    config.decryptKey = ucar_wtfpush();
    //主线程执行，保证timer正常。
    config.runInBackQueue = NO;
    [[UCARHttpBaseManager sharedManager] asyncHttpWithConfig:config
        success:^(NSDictionary *_Nonnull response, NSDictionary *_Nullable request) {
            UCARLoggerInfo(@"%@", response);
            [self parseResponse:response];
        }
        failure:^(NSDictionary *_Nullable response, NSDictionary *_Nullable request, NSError *_Nonnull error) {
            UCARLoggerInfo(@"response %@ error %@", response, error);
            [self retryRefreshIP];
        }];
}

- (void)parseResponse:(NSDictionary *)response {
    //子弹型代码，goodbye
    NSString *result = response[@"result"];
    if (![result isEqualToString:@"success"]) {
        [self retryRefreshIP];
        return;
    }
    NSArray<NSDictionary *> *secondary = response[@"secondary"];
    NSArray<NSDictionary *> *port = response[@"port"];
    if (port.count < 1 && secondary.count < 1) {
        [self retryRefreshIP];
        return;
    }
    //优先使用secondary，无secondary时使用port
    NSArray<NSDictionary *> *IPDicts = secondary;
    if (secondary.count < 1) {
        IPDicts = port;
    }

    _secretKey = response[@"k"];
    NSMutableArray<UCARPushIPModel *> *IPs = [NSMutableArray array];
    [IPDicts enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        UCARPushIPModel *IPModel = [[UCARPushIPModel alloc] init];
        IPModel.host = obj[@"ip"];
        IPModel.port = [obj[@"port"] intValue];
        [IPs addObject:IPModel];
    }];
    _ports = IPs;
    _currentIPIndex = 0;
    _reconnectCounter = 0;
    // if you want to change heartbeat ratio，communicate with wangjianhua
    self.heartbeatTime = [response[@"h1"] doubleValue];
    [self connectServer];
}

- (void)retryRefreshIP {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self refreshIP];
    });
}
//============================
- (void)notifyServerReceiveSocketPacketSuccess:(NSString *)UUID {
    UCARSocketPacket *packet = [UCARSocketPacket socketPacketWithMessageType:UCARSocketMessageType_MESSAGE_RESP];
    packet.UUID = UUID;
    NSData *data = [packet encryptedDataWithEncryptKey:_secretKey];
    [self sendData:data];
}

- (BOOL)checkPacketUUID:(NSString *)UUID {
    if ([_packetUUIDPool containsObject:UUID]) {
        return NO;
    }

    [_packetUUIDPool addObject:UUID];

    if (_packetUUIDPool.count > UCARPushUUIDCacheCount) {
        [_packetUUIDPool removeObjectAtIndex:0];
    }

    //此处需要优化，可减少保存的频率
    [[NSUserDefaults standardUserDefaults] setObject:_packetUUIDPool forKey:UCARPushUUIDCacheKey];

    return YES;
}

- (void)dealReceivedPacket:(UCARSocketPacket *)packet {
    switch (packet.msgType) {
        case UCARSocketMessageType_HEARTBEAT_REQ:
        case UCARSocketMessageType_HEARTBEAT_RESP: {
            [self.delegate heartbeatSuccess];
            break;
        }
        case UCARSocketMessageType_MESSAGE_RESP:
            //消息回应包
            break;
        default: {
            NSString *UUID = packet.UUID;
            if ([self checkPacketUUID:UUID]) {
                [self.delegate receivePushPacket:packet];
            }
            [self notifyServerReceiveSocketPacketSuccess:UUID];
            break;
        }
    }
}

- (void)sendData:(NSData *)data {
    // 3倍心跳超时，失败后重连
    [_socket writeData:data withTimeout:_heartbeatTime * 3 tag:0];
}

- (void)receiveData {
    // 3倍心跳超时，失败后重连
    [_socket readDataWithTimeout:_heartbeatTime * 3 tag:0];
}
//==================================
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    [self receiveData];

    UCARLoggerDebug(@"UCARPushEngine didReadData");
    if (!data) {
        NSDictionary *error = @{@"msg" : @"DataNil", @"errorCode" : @(UCARSocketPacketErrorDataNil)};
        [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
        UCARLoggerError(@"SDTS_ERROR DataNil %ld %@", data.length, data);
        return;
    }
    if (data.length < 1) {
        NSDictionary *error = @{@"msg" : @"DataEmpty", @"errorCode" : @(UCARSocketPacketErrorDataEmpty)};
        [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
        UCARLoggerError(@"SDTS_ERROR DataEmpty %ld %@", data.length, data);
        return;
    }
    [_packetData appendData:data];
    NSData *leftData = [UCARSocketPacket filterSocketPacketsWithData:_packetData
                                                      withDecryptKey:_secretKey
                                                         finishBlock:^(UCARSocketPacket *packet) {
                                                             [self dealReceivedPacket:packet];
                                                         }];
    _packetData = [NSMutableData data];
    if (leftData) {
        [_packetData appendData:leftData];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    UCARLoggerInfo(@"didWriteDataWithTag");
    //写入后等待读取
    [self receiveData];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self.delegate socketDidConnect];

    NSString *tag = [_secretKey substringWithRange:NSMakeRange(1, 2)];
    NSString *content = [NSString stringWithFormat:@"%@#%@#%@#%@#%@", _deviceID, _appVersion, _sysName,
                                                   [UCARHttpBaseManager sharedManager].networkStatus, tag];
    UCARSocketPacket *packet = [UCARSocketPacket socketPacketWithMessageType:UCARSocketMessageType_SESSION_START_REQ];
    packet.UUID = _deviceID;
    packet.businessType = 0;
    packet.content = content;
    NSData *data = [packet encryptedDataWithEncryptKey:ucar_wtfpush()];
    [self sendData:data];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [self.delegate socketDidDisconnect];
    if (_engineRunning) {
        [self connectServer];
    }
}

@end
