//
//  UCARGateKeeper.m
//  GateKeeper
//
//  Created by linux on 16/2/18.
//  Copyright © 2016年 Arlen. All rights reserved.
//

#import "UCARGateKeeperManager.h"
#import <UCARNetwork/UCARHttpBaseManager.h>
#import <UCARUtility/UCAREnvConfig.h>
#import <UCARUtility/UCARUtility.h>

static NSString *const UCARUserDefaultsKeyGateKeeper = @"UCARGateKeeper";
static NSString *const UCARHttpKeyGateKeeperServerDomain = @"GateKeeperServerDomain";
static NSString *const UCARURL_GK_BATCH = @"/batchcontrol";

@interface UCARGateKeeperManager ()

@property (nonatomic, strong) NSMutableDictionary *valueDict;

@property (nonatomic) NSString *appVersion;
@property (nonatomic) NSString *cid;

@end

@implementation UCARGateKeeperManager

+ (instancetype)sharedInstance {
    static UCARGateKeeperManager *manager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[UCARGateKeeperManager alloc] init];
    });
    return manager;
}

+ (void)initServiceWithConfig:(NSString *)configFileName appVersion:(NSString *)appVersion cid:(NSString *)cid {
    [[self sharedInstance] initServiceWithConfig:configFileName appVersion:appVersion cid:cid];
}

+ (void)fetchGateKeeperValueForKey:(NSString *)key
                 completionHandler:(GateKeeperValueFetchCompletionHandler)completionHandler {
    if (key.length == 0) {
        UCARLoggerDebug(@"error, wrong key for fetchGateKeeperValue");
        return;
    }

    if (!completionHandler) {
        UCARLoggerDebug(@"error, wrong completionHandler for fetchGateKeeperValue");
        return;
    }

    UCARGateKeeperManager *manager = [self sharedInstance];
    NSNumber *value = [manager GateKeeperValueForKey:key];
    completionHandler(value.boolValue);
}

- (void)initServiceWithConfig:(NSString *)configFileName appVersion:(NSString *)appVersion cid:(NSString *)cid;
{
    _appVersion = appVersion;
    _cid = cid;

    //默认值优先级，NSUserDeufalts -> Defatult.plist
    NSString *GateKeeperConfigPath = [[NSBundle mainBundle] pathForResource:configFileName ofType:@"plist"];
    NSDictionary *defaultValueDict = [NSDictionary dictionaryWithContentsOfFile:GateKeeperConfigPath];
    _valueDict = [defaultValueDict mutableCopy];

    NSDictionary *lastValueDict = [[NSUserDefaults standardUserDefaults] objectForKey:UCARUserDefaultsKeyGateKeeper];
    //比对键值
    [lastValueDict enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        self.valueDict[key] = obj;
    }];

    // update value
    [self fetchAllGateKeeperValues];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _valueDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setGateKeeperValues:(NSDictionary *)response {
    // 配置的值
    NSDictionary *moduleFlag = response[@"moduleFlag"];
    // 请求状态
    NSDictionary *moduleStatus = response[@"moduleStatus"];
    NSMutableDictionary *storedValueDict = [_valueDict mutableCopy];
    // 记录 storedValueDict 的值是否有更新
    __block BOOL storedValueUpdate = NO;
    [moduleFlag enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        // 配置状态
        NSNumber *mStatus = moduleStatus[key];
        if (mStatus.integerValue == 0) {
            // 成功请求 更新本地的值
            storedValueDict[key] = obj;
            storedValueUpdate = YES;
        }
    }];

    if (!storedValueUpdate) {
        // 值没有更新, 不用重复存储
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] setObject:storedValueDict forKey:UCARUserDefaultsKeyGateKeeper];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

- (NSNumber *)GateKeeperValueForKey:(NSString *)key {
    return _valueDict[key];
    ;
}

- (void)fetchAllGateKeeperValues {
    //后台的百分比算法：对UID hash后取余
    //故使用UID即可
    NSString *uid = [UCARSystemInfo idfvString];
    NSString *moduleNames = [_valueDict.allKeys componentsJoinedByString:@","];

    NSDictionary *params =
        @{@"moduleNames" : moduleNames, @"uid" : uid, @"appVersion" : _appVersion, @"mapiVersion" : _cid};

    UCARHttpBaseConfig *config = [UCARHttpBaseConfig defaultConfig];
    config.domain = [self gateKeeperDomain];
    config.subURL = UCARURL_GK_BATCH;
    config.parameters = params;
    config.httpdnsEnable = NO;
    [[UCARHttpBaseManager sharedManager] asyncHttpWithConfig:config
        success:^(NSDictionary *response, NSDictionary *request) {
            UCARLoggerDebug(@"response %@", response);
            NSNumber *status = response[@"status"];
            if (status.integerValue == 0) {
                [self setGateKeeperValues:response];
            }
        }
        failure:^(NSDictionary *response, NSDictionary *request, NSError *error) {
            UCARLoggerDebug(@"error %@", error);
        }];
}

- (NSString *)gateKeeperDomain {
    //获取域名
    NSString *envKey = [UCAREnvConfig getCurrentEnvKey];
    NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [selfBundle pathForResource:@"UCARGateKeeper" ofType:@"bundle"];
    NSBundle *configBundle = [NSBundle bundleWithPath:bundlePath];

    NSString *configPath = [configBundle pathForResource:@"ucargatekeeperconfig" ofType:@"plist"];
    NSDictionary *httpConfig = [NSDictionary dictionaryWithContentsOfFile:configPath];
    NSDictionary *currentConfig = httpConfig[envKey];
    NSString *domain = currentConfig[UCARHttpKeyGateKeeperServerDomain];
    return domain;
}

@end
