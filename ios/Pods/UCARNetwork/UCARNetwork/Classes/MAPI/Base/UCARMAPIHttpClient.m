//
//  UCARMAPIHttpClient.m
//  Pods
//
//  Created by linux on 2017/7/26.
//
//

#import "UCARMAPIHttpClient.h"
#import "UCARSecurityPolicy.h"
#import <UCARMonitor/UCARMonitorStore.h>
#import <UCARUtility/UCARUtility.h>
#import <UCARDeviceToken/UCARDeviceToken.h>

NSString *const UCARURLPCARRefreshKey = @"/resource/common/refreshKey";

NSString *ucar_wtfmapi() {
    const char *method = __FUNCTION__;

    unsigned char key[] = {
        0x97, 0xD9, 0x5C, 0xF2, 0x49, 0xC1, 0xB0, 0x6E, 0xBC, 0xAC,
        0x5C, 0x41, 0x66, 0x4C, 0x92, 0x4B, 0xE7, 0x38, 0x51, 0x7D,
    };

    return ucar_generateKey(method, key, 20);
}

static dispatch_queue_t http_private_request_queue() {
    static dispatch_queue_t http_private_request_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        http_private_request_queue =
            dispatch_queue_create("com.szzc.ucar.http.privaterequestqueue", DISPATCH_QUEUE_SERIAL);
    });
    return http_private_request_queue;
}

@interface UCARHttpPrivateRequest : NSObject

@property (nonatomic, strong) UCARMAPIHttpConfig *config;
@property (nonatomic, copy) UCARHttpSuccessBlock successBlock;
@property (nonatomic, copy) UCARHttpFailureBlock faillureBlock;

@end

@implementation UCARHttpPrivateRequest

@end

@interface UCARMAPIHttpClient ()

@property (nonatomic) NSMutableArray<UCARHttpPrivateRequest *> *privateRequests;

@end

@implementation UCARMAPIHttpClient

- (void)setAPISessionID:(NSString *)APISessionID {
    _APISessionID = APISessionID;
    [self.storeUserDefaults setObject:APISessionID forKey:self.sessionIDStoreKey];
    [UCARMonitorStore sharedStore].sessionID = APISessionID;
}

- (void)setAPISecretKey:(NSString *)APISecretKey {
    _APISecretKey = APISecretKey;
    [self.storeUserDefaults setObject:APISecretKey forKey:self.APISecretKeyStoreKey];
}

- (void)setAPISecretKeyPlainText:(NSString *)APISecretKeyPlainText {
    _APISecretKeyPlainText = APISecretKeyPlainText;
    [self.storeUserDefaults setObject:APISecretKeyPlainText forKey:self.APISecretKeyPlainTextStoreKey];
}

- (void)setAPISecretKeyEncrypted:(NSString *)APISecretKeyEncrypted {
    _APISecretKeyEncrypted = APISecretKeyEncrypted;
    [self.storeUserDefaults setObject:APISecretKeyEncrypted forKey:self.APISecretKeyEncryptedStoreKey];
}

- (void)setDomainInfo:(NSDictionary *)domainInfo {
    _domainInfo = domainInfo;
    [self.storeUserDefaults setObject:domainInfo forKey:self.domainInfoStoreKey];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _httpDNSDomainParseKey = @"mapi";
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    long initEventID = 0;
    NSNumber *eventID = [self.storeUserDefaults objectForKey:UCAREventIDStoreKey];
    if (eventID) {
        initEventID = eventID.longValue;
    }
    [UCAREventIDGenerator initEventID:initEventID];

    NSString *sessionID = [self.storeUserDefaults stringForKey:self.sessionIDStoreKey];
    if (sessionID) {
        self.APISessionID = sessionID;
    } else {
        //外部需要取值，不可赋nil
        self.APISessionID = @"";
    }

    self.MAPIReady = YES;
    self.APISecretKey = [self.storeUserDefaults objectForKey:self.APISecretKeyStoreKey];
    self.APISecretKeyEncrypted = [self.storeUserDefaults objectForKey:self.APISecretKeyEncryptedStoreKey];
    self.APISecretKeyPlainText = [self.storeUserDefaults objectForKey:self.APISecretKeyPlainTextStoreKey];
    self.MAPIUploadKeyRetryCount = 0;

    self.refreshKeyTime = 0.0;

    // 在 PCAR 与 RCAR 中不用处理
    if (self.domainInfoStoreKey) {
        [self initDomainInfoWithStoreKey:self.domainInfoStoreKey];
    }
}

//==========================================
- (void)addPrivateRequestWithWithConfig:(UCARMAPIHttpConfig *)config
                                success:(UCARHttpSuccessBlock)successBlock
                                failure:(UCARHttpFailureBlock)failureBlock {
    //缓存
    UCARHttpPrivateRequest *privateRequest = [[UCARHttpPrivateRequest alloc] init];
    privateRequest.config = config;
    privateRequest.successBlock = successBlock;
    privateRequest.faillureBlock = failureBlock;
    dispatch_async(http_private_request_queue(), ^{
        if (!self.privateRequests) {
            self.privateRequests = [[NSMutableArray alloc] init];
        }
        [self.privateRequests addObject:privateRequest];
    });
}

- (void)runPrivateRequests {
    dispatch_async(http_private_request_queue(), ^{
        [self.privateRequests
            enumerateObjectsUsingBlock:^(UCARHttpPrivateRequest *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                [self asyncHttpWithConfig:obj.config success:obj.successBlock failure:obj.faillureBlock];
            }];
        [self.privateRequests removeAllObjects];
        self.privateRequests = nil;
    });
}

//=============================

- (NSURLSessionDataTask *)asyncHttpWithConfig:(UCARMAPIHttpConfig *)config
                                      success:(UCARHttpSuccessBlock)successBlock
                                      failure:(UCARHttpFailureBlock)failureBlock {
#ifdef DEBUG
    if (config.internalDebug) {
        return [self servertestWithConfig:config success:successBlock failure:failureBlock];
    }
#endif

    // MAPI未准备完毕之前，缓存除APISecretKey请求之外的所有请求
    if ((!self.MAPIReady) && (config.allowCache)) {
        [self addPrivateRequestWithWithConfig:config success:successBlock failure:failureBlock];
        return nil;
    }
    config.needDecrypt = NO;
    config.decryptKey = _APISecretKey;

    config.originParameters = config.parameters;
    config.parameters = [self reviseMAPIParametersForConfig:config];
    UCARHttpSuccessBlock httpSuccessBlock = ^(id response, NSDictionary *request) {
        [self monitorDelayWithConfig:config];
        NSError *httpError = nil;

        response = [self decryptResponse:response withConfig:config error:&httpError];

        //序列化错误
        if (httpError) {
            [self.requestDelegate requestFailureWithConfig:config response:response error:httpError];
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(response, config.originParameters, httpError);
            });

            return;
        }

        //判定SessionID值
        NSNumber *code = response[UCARHttpResponseKeyCode];
        if (code.integerValue != UCARHttpMAPICodeSuccess) {
            NSError *error = [NSError errorWithDomain:UCARHttpMAPIErrorDomain
                                                 code:code.integerValue
                                             userInfo:@{@"userInfo" : response}];
#ifdef DEBUG
            [self logForConfig:config response:response error:error];
#endif
            [self monitorFailureWithConfig:config response:response error:error];
            [self.requestDelegate requestFailureWithConfig:config response:response error:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(response, config.originParameters, error);
            });
            return;
        }
#ifdef DEBUG
        [self logForConfig:config response:response error:nil];
#endif
        [self.requestDelegate requestSuccessWithConfig:config response:response];
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(response, config.originParameters);
        });
    };

    UCARHttpFailureBlock httpFailureBlock = ^(id response, NSDictionary *request, NSError *error) {
        [self monitorFailureWithConfig:config response:response error:error];
        [self.requestDelegate requestFailureWithConfig:config response:response error:error];
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock(response, config.originParameters, error);
        });
    };

    return [[UCARHttpBaseManager sharedManager] asyncHttpWithConfig:config
                                                            success:httpSuccessBlock
                                                            failure:httpFailureBlock];
}

- (NSMutableDictionary *)reviseMAPIParametersForConfig:(UCARMAPIHttpConfig *)config {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //所有加密接口均统计eventID
    dict[UCARHttpKeyEventID] = config.eventID;

    if (config.customCid) {
        dict[@"cid"] = config.customCid;
    } else {
        dict[@"cid"] = config.cid;
    }

    if (_APISessionID.length > 0) {
        dict[@"uid"] = _APISessionID;
    }

    if (config.appVersion.length > 0) {
        dict[@"version"] = config.appVersion;
    }

    NSDictionary *params = config.parameters;
    if (config.refreshKeyRequest) {
        dict[UCARHttpKeySecretKey] = params[UCARHttpKeySecretKey];
        dict[UCARHttpKeyDeviceID] = params[UCARHttpKeyDeviceID];
        // do something
        params = nil;
    }

    if (params.count > 0) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        NSString *qValue = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        qValue = [NSString AESForEncry:qValue WithKey:_APISecretKey];
        //将请求参数编入url中
        dict[@"q"] = qValue;
    }

    //计算签名
    NSMutableArray *dictArray = [NSMutableArray arrayWithCapacity:dict.count];
    for (NSString *key in dict.allKeys) {
        NSString *string = [NSString stringWithFormat:@"%@=%@", key, dict[key]];
        [dictArray addObject:string];
    }

    NSArray *array = [dictArray sortedArrayUsingSelector:@selector(compare:)];
    NSString *signStr = [array componentsJoinedByString:@";"];
    signStr = [NSString stringWithFormat:@"%@%@", signStr, _APISecretKey];
    dict[@"sign"] = [signStr doMD5String];

    return dict;
}

//一些特殊接口
- (NSURLRequest *)fullGetURLRequestForConfig:(UCARMAPIHttpConfig *)config {
    config.httpdnsEnable = NO;
    NSDictionary *dict = [self reviseMAPIParametersForConfig:config];
    NSString *fullURLString = [[UCARHttpBaseManager sharedManager] fullURLForConfig:config];
    NSURLRequest *request =
        [[UCARHttpBaseManager sharedManager].httpQueueManager.requestSerializer requestWithMethod:@"GET"
                                                                                        URLString:fullURLString
                                                                                       parameters:dict
                                                                                            error:nil];
    return request;
}

- (NSDictionary *)decryptResponse:(NSDictionary *)response
                       withConfig:(UCARMAPIHttpConfig *)config
                            error:(NSError *_Nullable __autoreleasing *)httpError {
    NSDictionary *responseDict = response;
    NSString *content = responseDict[UCARHttpResponseKeyContent];
    if (content.length == 0) {
        NSMutableDictionary *tmpDict = [responseDict mutableCopy];
        tmpDict[UCARHttpResponseKeyContent] = @"";
        responseDict = tmpDict;
        return responseDict;
    }

    content = [NSString AESForDecry:content WithKey:config.decryptKey];
    if (!content) {
        if (!(*httpError)) {
            *httpError = [NSError errorWithDomain:UCARHttpErrorDomain
                                             code:UCARHttpErrorCodeDecryptFailed
                                         userInfo:@{@"desc" : @"DecryptFailed"}];
        }

        NSMutableDictionary *tmpDict = [responseDict mutableCopy];
        tmpDict[UCARHttpResponseKeyContent] = @"";
        responseDict = tmpDict;
        return responseDict;
    }

    if ([content hasPrefix:@"["] || [content hasPrefix:@"{"]) {
        NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
        id decryptedContent = [[UCARHttpBaseManager sharedManager].jsonSerializer responseObjectForResponse:nil
                                                                                                       data:contentData
                                                                                                      error:nil];
        if (!decryptedContent) {
            if (!(*httpError)) {
                *httpError = [NSError errorWithDomain:UCARHttpErrorDomain
                                                 code:UCARHttpErrorCodeJSONParseFailed
                                             userInfo:@{@"desc" : @"JSONParseFailed"}];
            }

            NSMutableDictionary *tmpDict = [responseDict mutableCopy];
            tmpDict[UCARHttpResponseKeyContent] = @"";
            responseDict = tmpDict;
            return responseDict;
        } else {
            NSMutableDictionary *tmpDict = [responseDict mutableCopy];
            tmpDict[UCARHttpResponseKeyContent] = decryptedContent;
            responseDict = tmpDict;
            return responseDict;
        }
    } else {
        NSMutableDictionary *tmpDict = [responseDict mutableCopy];
        tmpDict[UCARHttpResponseKeyContent] = content;
        responseDict = tmpDict;
        return responseDict;
    }
}

//=============refreshKey=================
//====================================
// dynamic key
- (void)uploadDynamicKey:(BOOL)increaseRetryCount config:(UCARMAPIHttpConfig *)config {
    if (increaseRetryCount) {
        _MAPIUploadKeyRetryCount++;
    }
    [[UCARMonitorStore sharedStore] storeEvent:@"MY_my" remark:@{@"position" : @"getKey", @"retryCount" : @(_MAPIUploadKeyRetryCount), @"origin" : @"", @"rsaEncrypted" : @""}];
    NSString *keyStr = nil;
    if (_MAPIUploadKeyRetryCount < 4) {
        keyStr = [self.APISecretKey stringByAppendingString:@"-1"];
    } else {
        keyStr = [self.APISecretKey stringByAppendingString:@"-0"];
    }
    [[UCARMonitorStore sharedStore] storeEvent:@"MY_my" remark:@{@"position" : @"beforeRSA", @"retryCount" : @(_MAPIUploadKeyRetryCount), @"origin" : @"", @"rsaEncrypted" : @""}];
    // RSA公钥加密
    //此处用到了keychain store，必须保证keychain store开启
    NSString *APISecretKey = [RSA encryptString:keyStr publicKey:UCARHttpRSAPublicKey];
    APISecretKey = [APISecretKey stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    APISecretKey = [APISecretKey stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    [[UCARMonitorStore sharedStore] storeEvent:@"MY_my" remark:@{@"position" : @"afterRSA", @"retryCount" : @(_MAPIUploadKeyRetryCount), @"origin" : @"", @"rsaEncrypted" : @""}];
    //加密失败保护，使用上次的备份
    if (APISecretKey.length == 0) {
        [[UCARMonitorStore sharedStore] storeEvent:@"MY_RSA_Fail" remark:@{@"origin" : keyStr, @"retryCount" : @(_MAPIUploadKeyRetryCount)}];
        NSString *refreshKey = self.APISecretKeyPlainText;
        if (refreshKey) {
            self.APISecretKey = refreshKey;
            APISecretKey = self.APISecretKeyEncrypted;
        } else {
            [self retryUploadDynamicKey:NO config:config];
            return;
        }
    }
    [[UCARMonitorStore sharedStore] storeEvent:@"MY_my" remark:@{@"position" : @"beforeUpload", @"retryCount" : @(_MAPIUploadKeyRetryCount), @"origin" : keyStr, @"rsaEncrypted" : APISecretKey}];
    self.APISecretKeyPlainText = self.APISecretKey;
    self.APISecretKeyEncrypted = APISecretKey;

    config.parameters =
        @{UCARHttpKeySecretKey : _APISecretKeyEncrypted, UCARHttpKeyDeviceID : [UCARDeviceToken deviceUUID]};

    config.allowCache = NO;
    config.refreshKeyRequest = YES;
    config.autoDealMAPIError = NO;
    config.autoDealNetworkError = NO;

    __weak typeof(self) weakSelf = self;
    [self asyncHttpWithConfig:config
        success:^(NSDictionary *_Nonnull response, NSDictionary *_Nullable request) {
            [weakSelf uploadDynamicKeySuccessWithResoponse:response];
        }
        failure:^(NSDictionary *_Nullable response, NSDictionary *_Nullable request, NSError *_Nonnull error) {
            if ([error.domain isEqualToString:UCARHttpErrorDomain] ||
                [error.domain isEqualToString:UCARHttpMAPIErrorDomain]) {
                [weakSelf retryUploadDynamicKey:YES config:config];
            } else {
                [weakSelf retryUploadDynamicKey:NO config:config];
            }
        }];
}

- (void)retryUploadDynamicKey:(BOOL)increaseRetryCount config:(UCARMAPIHttpConfig *)config {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self uploadDynamicKey:increaseRetryCount config:config];
    });
}

- (void)uploadDynamicKeySuccessWithResoponse:(NSDictionary *)response {
    self.APISessionID = response[UCARHttpResponseKeyUID];

    //注意此处bool取值，content = "false" ||"true"
    BOOL open = [response[UCARHttpResponseKeyContent] boolValue];
    if (!open) {
        self.APISecretKey = self.staticAPISecretKey;
    }
    _MAPIReady = YES;
    [self runPrivateRequests];
    NSDictionary *uidDic = @{@"uuid" : _APISessionID};
    if (open) {
        [[UCARMonitorStore sharedStore] storeEvent:@"MY_dtmy" remark:uidDic];
    } else {
        [[UCARMonitorStore sharedStore] storeEvent:@"MY_jtmy" remark:uidDic];
    }
}

- (void)refreshKeyWithConfig:(UCARMAPIHttpConfig *)config {
    //限制外部调用频率为10.0s
    if (_refreshKeyTime > 0) {
        NSTimeInterval now = CACurrentMediaTime();
        if (now - _refreshKeyTime < 10.0) {
            return;
        }
        _refreshKeyTime = now;
    } else {
        _refreshKeyTime = CACurrentMediaTime();
    }

    _MAPIReady = NO;
    self.APISecretKey = ucar_generateRandomKey(20);
    _MAPIUploadKeyRetryCount = 0;
    [self uploadDynamicKey:YES config:config];
}

- (void)refreshKey:(BOOL)init {
    UCARMAPIHttpConfig *config = [UCARMAPIHttpConfig defaultConfig];
    config.subURL = UCARURLPCARRefreshKey;
    config.domain = self.APIDomain;
    config.cid = self.cid;
    [self refreshKeyWithConfig:config];
}

//==============domain

- (void)initDomainInfoWithStoreKey:(NSString *)storeKey {
    NSString *configPath = [[UCARHttpBaseManager sharedManager] pathForResource:@"ucarhttpconfig" ofType:@"plist"];
    NSDictionary *httpConfig = [NSDictionary dictionaryWithContentsOfFile:configPath];
    NSString *envKey = [UCAREnvConfig getCurrentEnvKey];
    NSDictionary *currentConfig = httpConfig[envKey];
    NSDictionary *domainInfo = currentConfig[storeKey];

    //获取域名
    self.APIDomain = domainInfo[@"domain"];
    //    NSString *MAPIIP = domainInfo[@"ip"];
    //    [[UCARHttpBaseManager sharedManager] setDomain:self.APIDomain
    //    andIP:MAPIIP];
}

- (void)updateMAPIDomainAndIP {
    UCARHttpBaseConfig *config = [UCARHttpBaseConfig defaultConfig];
    config.domain = self.APIDomain;
    config.subURL = UCARURLHttpDNS;
    config.runInBackQueue = NO;
    [[UCARHttpBaseManager sharedManager] asyncHttpWithConfig:config
        success:^(NSDictionary *_Nonnull response, NSDictionary *_Nullable request) {
            [self parseHttpDNSFromResponse:response];
        }
        failure:^(NSDictionary *_Nullable response, NSDictionary *_Nullable request, NSError *_Nonnull error) {
            [self retryUpdateMAPIDomainAndIP];
        }];
}

- (void)parseHttpDNSFromResponse:(NSDictionary *)response {
    NSDictionary *mapi = response[self.httpDNSDomainParseKey];
    //    self.domainInfo = mapi;
    NSString *domain = mapi[UCARHttpKeyDomain];
    NSString *IP = mapi[UCARHttpKeyIP];
    if (IP) {
        //        [[UCARHttpBaseManager sharedManager] setDomain:self.APIDomain
        //        andIP:IP];
        [[UCARHttpBaseManager sharedManager]
            checkDNSHijackForDomain:self.APIDomain
                         withRealIP:IP
                        finishBlock:^(BOOL DNSHijacked, NSArray<NSString *> *_Nonnull IPs, NSError *_Nullable error) {
                            NSString *localIP = [IPs firstObject];
                            if (localIP) {
                                if (DNSHijacked) {
                                    [[UCARMonitorStore sharedStore] storeDNS:domain IP:IP hijackIP:localIP remark:@{}];
                                } else {
                                    [[UCARMonitorStore sharedStore] storeDNS:domain
                                                                          IP:IP
                                                                    hijackIP:UCARMonitorStoreDefaultValue
                                                                      remark:@{}];
                                }
                            }
                        }];
    }
}

- (void)retryUpdateMAPIDomainAndIP {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateMAPIDomainAndIP];
    });
}

- (void)monitorDelayWithConfig:(UCARMAPIHttpConfig *)config {
    CFTimeInterval endTime = CACurrentMediaTime();
    CFTimeInterval duration = endTime - config.requestSendTime;
    NSInteger durationMS = floor(duration * 1000);
    NSDictionary *remark = @{@"subURL" : config.subURL, @"duration" : @(durationMS)};
    [[UCARMonitorStore sharedStore] storeEvent:@"requestDuration" remark:remark];
}

- (void)monitorFailureWithConfig:(UCARMAPIHttpConfig *)config response:(NSDictionary *)response error:(NSError *)error {
    NSDictionary *logReq = @{};
    if (config.originParameters) {
        logReq = config.originParameters;
    }
    NSDictionary *logResp = @{};
    if (response) {
        logResp = response;
    }
    NSDictionary *logRemark = @{
        @"subURL" : config.subURL,
        @"request" : logReq,
        @"response" : logResp,
        @"errorCode" : @(error.code),
        @"errorDomain" : error.domain,
        @"errorDesc" : error.description
    };
    [[UCARMonitorStore sharedStore] storeException:@"httpError" stack:@{} remark:logRemark];
}

#ifdef DEBUG
- (NSURLSessionDataTask *)servertestWithConfig:(UCARMAPIHttpConfig *)config
                                       success:(UCARHttpSuccessBlock)successBlock
                                       failure:(UCARHttpFailureBlock)failureBlock {
    NSString *subURL = [config.subURL stringByReplacingOccurrencesOfString:@"/" withString:@""];
    subURL = [NSString stringWithFormat:@"/servertest/%@/", subURL];
    config.domain = @"10.101.44.111:9090";
    config.parameters = nil;
    config.subURL = subURL;
    config.needDecrypt = NO;
    config.httpsEnable = NO;
    config.httpdnsEnable = NO;
    config.runInBackQueue = NO;
    return [[UCARHttpBaseManager sharedManager] asyncHttpWithConfig:config success:successBlock failure:failureBlock];
}

- (void)logForConfig:(UCARMAPIHttpConfig *)config response:(NSDictionary *)response error:(NSError *)error {
    NSString *mobile = @"";
    if (self.getRealTimeLogIDBlock) {
        mobile = self.getRealTimeLogIDBlock();
    }
    if (!mobile) {
        mobile = @"";
    }

    NSDictionary *request = config.originParameters;
    if (!request) {
        request = config.parameters;
        if (!request) {
            request = @{};
        }
    }
    if (!response) {
        response = @{};
    }
    NSString *errorStr = error.description;
    if (!errorStr) {
        errorStr = @"";
    }

    [[UCARHttpBaseManager sharedManager] postLog:config.domain
                                          subURL:config.subURL
                                         request:request
                                        response:response
                                           error:errorStr
                                   realTimeLogID:mobile];
}
#endif

@end
