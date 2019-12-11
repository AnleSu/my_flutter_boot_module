//
//  UCARPushService.m
//  UCarDriver
//
//  Created by North on 2016/9/23.
//  Copyright © 2016年 szzc. All rights reserved.
//

#import "UCARPushService.h"
#import "UCARPushEngine.h"
#import <UCARClientSocket/UCarMessage.h>
#import <UCARMonitor/UCARMonitorStore.h>
#import <UCARNetwork/UCARNetwork.h>
#import <UCARUtility/UCARUtility.h>

NSString *const UCAREnvKeyPushDomain = @"UCARPushDomain";
NSString *const UCARJSONKeyPushType = @"pushType";

@interface UCARPushService () <UCARPushEngineDelegate>

@property (nonatomic)
    NSMutableDictionary<NSNumber *, NSMutableDictionary<NSString *, UCARPushReceiveHandler> *> *registers;

@property (nonatomic) UCARPushEngine *pushEngine;

@property (nonatomic, copy) NSString *deviceID;

@end

@implementation UCARPushService

+ (instancetype)sharedService {
    static UCARPushService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[UCARPushService alloc] init];
    });
    return service;
}

- (UCARPushEngine *)pushEngine {
    if (!_pushEngine) {
        _pushEngine = [[UCARPushEngine alloc] init];
        _pushEngine.delegate = self;
        _pushEngine.appVersion = @"";
        _pushEngine.sysName = @"";
        _pushEngine.netManagerHost = [self getDomainInfo];
        _pushEngine.reconnectTimes = 20;
    }
    return _pushEngine;
}

- (void)setAppVersion:(NSString *)appVersion {
    _appVersion = [appVersion copy];
    self.pushEngine.appVersion = appVersion;
}

- (void)setSysName:(NSString *)sysName {
    _sysName = [sysName copy];
    self.pushEngine.sysName = sysName;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _registers = [[NSMutableDictionary alloc] init];
        _serviceRunning = NO;
        _pushTypeIsBusinessType = YES;
        _deviceID = @"";
        _appVersion = @"";
        _sysName = @"";

        self.pushEngine.appVersion = _appVersion;
        self.pushEngine.sysName = _sysName;
    }
    return self;
}

- (NSString *)pathForResource:(NSString *)resource ofType:(NSString *)type {
    NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [selfBundle pathForResource:@"UCARPushEngine" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    return [resourceBundle pathForResource:resource ofType:type];
}

- (NSString *)getDomainInfo {
    NSString *configPath = [self pathForResource:@"config" ofType:@"plist"];
    NSDictionary *httpConfig = [NSDictionary dictionaryWithContentsOfFile:configPath];
    NSString *envKey = [UCAREnvConfig getCurrentEnvKey];
    NSDictionary *currentConfig = httpConfig[envKey];
    NSString *domainInfo = currentConfig[UCAREnvKeyPushDomain];
    return domainInfo;
}

- (void)startServiceWithDeviceID:(NSString *)deviceID {
    if (_serviceRunning) {
        return;
    }
    _serviceRunning = YES;
    //生成id
    _deviceID = deviceID;
    self.pushEngine.deviceID = deviceID;

    [self.pushEngine startEngine];

    [[UCARMonitorStore sharedStore] storeEvent:@"PUSH_start" remark:@{}];
}

- (void)stopService {
    _serviceRunning = NO;
    [self.pushEngine stopEngine];
    [[UCARMonitorStore sharedStore] storeEvent:@"PUSH_stop" remark:@{}];
}

- (void)registerPushService:(id)object forPushType:(NSInteger)pushType responseHandler:(UCARPushReceiveHandler)handler {
    NSString *key = [[NSString alloc] initWithFormat:@"%p", object];
    NSMutableDictionary *dict = _registers[@(pushType)];
    if (!dict) {
        dict = [[NSMutableDictionary alloc] init];
        _registers[@(pushType)] = dict;
    }
    dict[key] = [handler copy];
}

- (void)registerPushService:(nonnull id)object
               forPushTypes:(nonnull NSArray<NSNumber *> *)pushTypes
            responseHandler:(nonnull UCARPushReceiveHandler)handler {
    [pushTypes enumerateObjectsUsingBlock:^(NSNumber *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self registerPushService:object forPushType:obj.integerValue responseHandler:handler];
    }];
}

- (void)unregisterPushService:(id)object {
    NSString *objectKey = [[NSString alloc] initWithFormat:@"%p", object];
    [_registers enumerateKeysAndObjectsUsingBlock:^(
                    NSNumber *_Nonnull key, NSMutableDictionary<NSString *, UCARPushReceiveHandler> *_Nonnull obj,
                    BOOL *_Nonnull stop) {
        [obj removeObjectForKey:objectKey];
    }];
}

- (void)unregisterPushService:(id)object forPushType:(NSInteger)pushType {
    NSString *objectKey = [[NSString alloc] initWithFormat:@"%p", object];
    NSMutableDictionary *dict = _registers[@(pushType)];
    [dict removeObjectForKey:objectKey];
}

- (void)runHandlerForPushType:(NSInteger)pushType data:(NSDictionary *)data UUID:(NSString *)UUID {
    NSMutableDictionary<NSString *, UCARPushReceiveHandler> *dict = _registers[@(pushType)];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, UCARPushReceiveHandler _Nonnull obj,
                                              BOOL *_Nonnull stop) {
        obj(pushType, data, UUID);
    }];
}

// socket===========================
// v3
- (void)socketDidConnect {
    UCARLoggerInfo(@"UCARPushService v3 socketDidConnect");

    [[UCARMonitorStore sharedStore] storeEvent:@"PUSH_connect" remark:@{}];
}
- (void)socketDidDisconnect {
    UCARLoggerInfo(@"UCARPushService v3 socketDidDisconnect");

    [[UCARMonitorStore sharedStore] storeEvent:@"PUSH_disconnect" remark:@{}];
}

- (void)heartbeatSuccess {
    UCARLoggerInfo(@"UCARPushService v3 heartbeatSuccess");
}
- (void)receivePushPacket:(UCARSocketPacket *)packet {
    UCARLoggerInfo(@"UCARPushService v3 receivcePushMessage");
    UCARLoggerInfo(@"UCARPushService v3 uuid: %@ \nmessage: %@", packet.UUID, packet.content);

    // fuck order backend, wtf you push in content
    if ((![packet.content hasPrefix:@"{"]) && (![packet.content hasPrefix:@"["])) {
        packet.content = @"{}";
    }

    NSDictionary *remark = @{@"uuid" : packet.UUID, @"content" : packet.content};
    [[UCARMonitorStore sharedStore] storeEvent:@"SDTS" remark:remark];

    NSError *error = nil;
    NSData *data = [packet.content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        UCARLoggerInfo(@"UCARPushService v3 push 数据解析失败");
        NSDictionary *error = @{
            @"msg" : @"JSONParseFail",
            @"errorCode" : @(UCARSocketPacketErrorJSONParseFail),
            @"content" : packet.content
        };
        [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
        UCARLoggerDebug(@"SDTS_ERROR JSONParseFail %@", packet.content);
    } else {
        UCARLoggerDebug(@"UCARPushService v3 pushData %@", dict);
        NSInteger pushType = packet.businessType;
        if (!_pushTypeIsBusinessType) {
            pushType = [dict[UCARJSONKeyPushType] intValue];
        }
        [self runHandlerForPushType:pushType data:dict UUID:packet.UUID];
    }
}

@end
