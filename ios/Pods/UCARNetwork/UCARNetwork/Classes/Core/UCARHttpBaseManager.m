//
//  UCARHttpBaseManager.m
//  UCar
//
//  Created by KouArlen on 16/3/7.
//  Copyright © 2016年 zuche. All rights reserved.
//

#import "UCARHttpBaseManager.h"

#import "UCARHttpRequestSerializer.h"
#import "UCARSecurityPolicy.h"
#import <CFNetwork/CFNetwork.h>
#import <UCARMonitor/UCARMonitorStore.h>
#import <UCARUtility/UCARUtility.h>
#import <arpa/inet.h>

// All success && failure blocks will run in this queue
static dispatch_queue_t http_completion_queue() {
    static dispatch_queue_t http_completion_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        http_completion_queue = dispatch_queue_create("com.szzc.ucar.http.completionqueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return http_completion_queue;
}

@interface UCARHttpBaseManager ()

//保存domain与ip的映射关系，用于请求
//注意，此中保存的IP与域名为多对一关系，即一个IP对应一个域名，一个域名可对应多个IP。
@property (nonatomic) NSMutableDictionary<NSString *, NSString *> *domains;

//保存domain与ip的对应关系，用于dns
@property (nonatomic) NSMutableDictionary<NSString *, NSDictionary *> *checkDomains;

@end

@implementation UCARHttpBaseManager

+ (instancetype)sharedManager {
    static UCARHttpBaseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UCARHttpBaseManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isReachable = YES;
        _networkStatus = [self localizationForNetworkstatus:AFNetworkReachabilityStatusReachableViaWiFi];

        _domains = [[NSMutableDictionary alloc] init];

        _jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableLeaves];
        _jsonSerializer.removesKeysWithNullValues = YES;
        _jsonSerializer.acceptableContentTypes = nil;

        // wosign啊wosign, wtf
        _securityPolicy = [UCARSecurityPolicy defaultPolicy];
        _securityPolicy.allowInvalidCertificates = YES;
        _securityPolicy.validatesDomainName = NO;

        _httpQueueManager = [AFHTTPSessionManager manager];
        _httpQueueManager.securityPolicy = _securityPolicy;
        _httpQueueManager.requestSerializer = [UCARHttpRequestSerializer serializer];
        _httpQueueManager.requestSerializer.timeoutInterval = UCARHttpTimeOut;
        _httpQueueManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        ;
        _httpQueueManager.completionQueue = http_completion_queue();
        __weak UCARHttpBaseManager *weakSelf = self;
        _httpQueueManager.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        [_httpQueueManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            [weakSelf networkStatusChanged:status];
        }];
        [_httpQueueManager.reachabilityManager startMonitoring];

        _checkDomains = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *)pathForResource:(NSString *)resource ofType:(NSString *)type {
    NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [selfBundle pathForResource:@"UCARNetwork" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    return [resourceBundle pathForResource:resource ofType:type];
}

- (void)networkStatusChanged:(AFNetworkReachabilityStatus)status {
    if (status == AFNetworkReachabilityStatusNotReachable) {
        _isReachable = NO;
    } else {
        _isReachable = YES;
    }
    _networkStatus = [self localizationForNetworkstatus:status];
    [[UCARMonitorStore sharedStore] storeEvent:@"netChange" remark:@{@"net" : _networkStatus}];
}

- (NSString *)localizationForNetworkstatus:(AFNetworkReachabilityStatus)status {
    switch (status) {
    case AFNetworkReachabilityStatusUnknown:
    case AFNetworkReachabilityStatusReachableViaWiFi:
        return @"WIFI";
    case AFNetworkReachabilityStatusReachableViaWWAN:
        return @"WWAN";
    case AFNetworkReachabilityStatusNotReachable:
        return @"NotReachable";
    default:
        break;
    }
}

//==========================================

//完整接口
- (NSURLSessionDataTask *)asyncHttpWithConfig:(UCARHttpBaseConfig *)config
                                      success:(UCARHttpSuccessBlock)successBlock
                                      failure:(UCARHttpFailureBlock)failureBlock {

    NSString *fullURLString = [self fullURLForConfig:config];
    [self addHeaderForConfig:config];
    // local time, 不受网络时间，时区变更等影响
    config.requestSendTime = CACurrentMediaTime();

    __weak UCARHttpBaseManager *weakSelf = self;
    void (^httpSuccessBlock)(NSURLSessionDataTask *task, id responseObject) =
        ^(NSURLSessionDataTask *task, id responseObject) {
            UCARLoggerDebug(@"fullURL %@", task.currentRequest.URL.absoluteString);

            NSError *httpError = nil;

            id responseDict = [weakSelf decryptData:responseObject withConfig:config error:&httpError];

            //序列化错误
            if (httpError) {
                if (config.runInBackQueue) {
                    failureBlock(nil, config.parameters, httpError);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failureBlock(nil, config.parameters, httpError);
                    });
                }

            } else {
                if (config.runInBackQueue) {
                    successBlock(responseDict, config.parameters);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        successBlock(responseDict, config.parameters);
                    });
                }
            }
        };

    void (^httpFailureBlock)(NSURLSessionDataTask *task, NSError *error) =
        ^(NSURLSessionDataTask *task, NSError *error) {
            UCARLoggerDebug(@"fullURL %@", task.currentRequest.URL.absoluteString);
            if (config.runInBackQueue) {
                failureBlock(nil, config.parameters, error);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock(nil, config.parameters, error);
                });
            }
        };

    NSURLSessionDataTask *task = nil;
    switch (config.httpMethod) {
    case UCARHttpMethodGet: {
        task = [_httpQueueManager GET:fullURLString
                           parameters:config.parameters
                             progress:nil
                              success:httpSuccessBlock
                              failure:httpFailureBlock];
    } break;
    case UCARHttpMethodPost: {
        if (config.postDataFormatBlock) {
            task = [_httpQueueManager POST:fullURLString
                                parameters:config.parameters
                 constructingBodyWithBlock:config.postDataFormatBlock
                                  progress:nil
                                   success:httpSuccessBlock
                                   failure:httpFailureBlock];
        } else {
            task = [_httpQueueManager POST:fullURLString
                                parameters:config.parameters
                                  progress:nil
                                   success:httpSuccessBlock
                                   failure:httpFailureBlock];
        }
    }

    default:
        break;
    }

    return task;
}

- (id)decryptData:(NSData *)responseData
       withConfig:(UCARHttpBaseConfig *)config
            error:(NSError *__autoreleasing _Nullable *)httpError {
    if (!config.needParse) {
        return responseData;
    }

    if (config.needDecrypt) {
        //注意：后台出现过返回数据未加密的情况（导致解密失败），此处需要增加解密失败的情况。
        //目前暂归入数据格式化错误
        NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //注意，后台出现过reponse为null的情况，而base64不可传入nil，故此处需要一个保护
        if (string) {
            UCARLoggerDebug(@"http Original Response: %@", string);
            if ([string hasPrefix:@"["] || [string hasPrefix:@"{"]) {
                //明文返回，不再解密
                // do nothing
            } else {
                string = [NSString AESForDecry:string WithKey:config.decryptKey];
                UCARLoggerDebug(@"http decrypted Response: %@", string);
                responseData = [string dataUsingEncoding:NSUTF8StringEncoding];
                if (!responseData) {
                    *httpError = [NSError errorWithDomain:UCARHttpErrorDomain
                                                     code:UCARHttpErrorCodeDecryptFailed
                                                 userInfo:@{@"desc" : @"DecryptFailed"}];
                }
            }

        } else {
            *httpError = [NSError errorWithDomain:UCARHttpErrorDomain
                                             code:UCARHttpErrorCodeResponseNull
                                         userInfo:@{@"desc" : @"ResponseNull"}];
        }
    }

    NSDictionary *responseDict = nil;
    if (!(*httpError)) {
        if (responseData) {
            responseDict = [self.jsonSerializer responseObjectForResponse:nil data:responseData error:nil];
            if (!responseDict) {
                *httpError = [NSError errorWithDomain:UCARHttpErrorDomain
                                                 code:UCARHttpErrorCodeJSONParseFailed
                                             userInfo:@{@"desc" : @"JSONParseFailed"}];
            }
        } else {
            *httpError = [NSError errorWithDomain:UCARHttpErrorDomain
                                             code:UCARHttpErrorCodeResponseNull
                                         userInfo:@{@"desc" : @"ResponseNull"}];
        }
    }
    UCARLoggerDebug(@"http Original json: %@", responseDict);
    return responseDict;
}

- (NSString *)fullURLForConfig:(UCARHttpBaseConfig *)config {
    NSString *domain = config.domain;
    NSString *IP = self.domains[domain];
    if (IP && config.httpdnsEnable) {
        domain = IP;
    }
    NSString *protocol = @"https";
    if (!config.httpsEnable) {
        protocol = @"http";
    }
    return [NSString stringWithFormat:@"%@://%@%@", protocol, domain, config.subURL];
}

- (void)addHeaderForConfig:(UCARHttpBaseConfig *)config {
    NSMutableDictionary *header = [config.header mutableCopy];
    if (!header) {
        header = [NSMutableDictionary dictionary];
    }
    header[@"Host"] = config.domain;
    NSMutableDictionary *parameters = [config.parameters mutableCopy];
    if (!parameters) {
        parameters = [NSMutableDictionary dictionary];
    }
    parameters[UCARHttpRequestHeader] = header;
    config.parameters = parameters;
}

- (void)downloadFileFromURLString:(NSString *)fileURL
                           toPath:(NSString *)path
                completionHandler:
                    (void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL]];
    NSURLSessionDownloadTask *task = [_httpQueueManager
        downloadTaskWithRequest:request
                       progress:nil
                    destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
                        return [NSURL fileURLWithPath:path];
                    }
              completionHandler:completionHandler];
    [task resume];
}

- (void)setDomain:(NSString *)domain andIP:(NSString *)IP {
    if (domain && IP) {
        _domains[domain] = IP;
        self.securityPolicy.IPs[IP] = domain;
    }
}

//==========================================
//域名劫持检查
- (void)checkDNSHijackForDomain:(NSString *)domain
                     withRealIP:(NSString *)realIP
                    finishBlock:(UCARDNSCheckFinishBlock)finishBlock {
    domain = [self cleanHostFromMixedHost:domain];
    realIP = [self cleanHostFromMixedHost:realIP];

    Boolean success;

    CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)domain);
    CFHostClientContext ctx = {.info = (__bridge void *)self};
    success = CFHostSetClient(host, DNSResolverHostClientCallback, &ctx);
    if (!success) {
        UCARLoggerDebug(@"UCARHttpBaseManager -- error, dns解析错误");
        CFRelease(host);
        return;
    }

    NSString *domainKey = [NSString stringWithFormat:@"%p", host];
    NSDictionary *domainInfo = @{UCARHttpKeyIP : realIP, @"callback" : finishBlock};
    _checkDomains[domainKey] = domainInfo;

    // you must make sure that 'checkDNSHijackForDomain' and
    // 'stopCheckDNSHijackForHost' run in same thread
    CFHostScheduleWithRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

    CFStreamError error;
    success = CFHostStartInfoResolution(host, kCFHostAddresses, &error);

    if (!success) {
        [self stopCheckDNSHijackForHost:host noError:NO];
    }

    BOOL noError = ((error.domain == 0) && (error.error == 0));
    if (!noError) {
        [self stopCheckDNSHijackForHost:host noError:NO];
    }
}

//去除端口号
- (NSString *)cleanHostFromMixedHost:(NSString *)host {
    //倒序查找
    NSRange portRange = [host rangeOfString:@":" options:NSBackwardsSearch];
    if (portRange.location == NSNotFound) {
        //纯ipv4或域名
        return host;
    } else {
        NSRange ipv6Range = [host rangeOfString:@"]" options:NSBackwardsSearch];
        if (ipv6Range.location == NSNotFound) {
            //带端口的ipv4或域名
            return [host substringToIndex:portRange.location];
        } else {
            if (ipv6Range.location > portRange.location) {
                //纯ipv6
                return host;
            } else {
                //带端口的ipv6
                return [host substringToIndex:portRange.location];
            }
        }
    }
}

static void DNSResolverHostClientCallback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error,
                                          void *info) {
    UCARHttpBaseManager *manager = (__bridge UCARHttpBaseManager *)info;

    BOOL noError = (error == NULL) || ((error->domain == 0) && (error->error == 0));
    [manager stopCheckDNSHijackForHost:theHost noError:noError];
}

- (void)stopCheckDNSHijackForHost:(CFHostRef)host noError:(BOOL)noError {
    NSString *domainKey = [NSString stringWithFormat:@"%p", host];
    NSDictionary *domainInfo = _checkDomains[domainKey];
    NSString *IP = domainInfo[UCARHttpKeyIP];
    UCARDNSCheckFinishBlock finishBlock = domainInfo[@"callback"];
    [_checkDomains removeObjectForKey:domainKey];
    NSError *error = nil;
    BOOL DNSHijacked = YES;
    NSMutableArray *IPs = [NSMutableArray array];
    if (noError) {
        UCARLoggerDebug(@"UCARHttpBaseManager -- success, dns解析完成");
        Boolean hasBeenResolved;
        CFArrayRef addressArray = CFHostGetAddressing(host, &hasBeenResolved);
        if (hasBeenResolved) {
            NSArray *addrArray = (__bridge NSArray *)addressArray;
            const char *realIP = IP.UTF8String;
            for (NSData *data in addrArray) {
                struct sockaddr *sock_addr = (struct sockaddr *)data.bytes;
                if (sock_addr->sa_family == AF_INET) {
                    struct sockaddr_in *sock_ptr = (struct sockaddr_in *)data.bytes;
                    char address[INET_ADDRSTRLEN];
                    if (inet_ntop(AF_INET, (const void *)&sock_ptr->sin_addr, address, INET_ADDRSTRLEN) != NULL) {
                        NSString *localIP = [NSString stringWithCString:address encoding:NSUTF8StringEncoding];
                        [IPs addObject:localIP];
                        if (strcmp(address, realIP) == 0) {
                            DNSHijacked = NO;
                            break;
                        }
                    }

                } else {
                    struct sockaddr_in6 *sock_ptr = (struct sockaddr_in6 *)data.bytes;
                    char address[INET6_ADDRSTRLEN];
                    if (inet_ntop(AF_INET6, (const void *)&sock_ptr->sin6_addr, address, INET6_ADDRSTRLEN) != NULL) {
                        NSString *localIP = [NSString stringWithCString:address encoding:NSUTF8StringEncoding];
                        [IPs addObject:localIP];
                        if (strcmp(address, realIP) == 0) {
                            DNSHijacked = NO;
                            break;
                        }
                        // IPv6进行一次额外的比对，防止IP为IPv4转换成的IPv6
                        const char *IPv4 = [self getIPv4FromIPv6:address];
                        if (IPv4 && strcmp(IPv4, realIP) == 0) {
                            DNSHijacked = NO;
                            break;
                        }
                    }
                }
            }
            if (DNSHijacked) {
                error = [NSError errorWithDomain:UCARDNSCheckErrorDomain
                                            code:UCARDNSCheckErrorCodeHijacked
                                        userInfo:nil];
            }
        } else {
            UCARLoggerDebug(@"UCARHttpBaseManager -- error, dns解析错误");
            error = [NSError errorWithDomain:UCARDNSCheckErrorDomain
                                        code:UCARDNSCheckErrorCodeDNSParseError
                                    userInfo:nil];
        }
    } else {
        UCARLoggerDebug(@"UCARHttpBaseManager -- error, dns解析错误");
        error = [NSError errorWithDomain:UCARDNSCheckErrorDomain code:UCARDNSCheckErrorCodeDNSParseError userInfo:nil];
    }

    CFHostSetClient(host, NULL, NULL);
    CFHostUnscheduleFromRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    CFRelease(host);

    finishBlock(DNSHijacked, IPs, error);
}

- (const char *)getIPv4FromIPv6:(const char *)IPv6 {
    //注意：目前并没有明确的算法支持IPv6向IPv4的映射，下面的算法来自bing出的一些资料
    //针对当前的预生产和生产的IP，可满足需求
    NSString *addrStr = [[NSString alloc] initWithCString:IPv6 encoding:NSUTF8StringEncoding];
    NSArray *addrArray = [addrStr componentsSeparatedByString:@":"];
    NSUInteger count = addrArray.count;
    if (count >= 2) {
        NSString *addrHead = addrArray[count - 2];
        NSString *addrTail = addrArray[count - 1];
        unsigned addrHex = 0;
        NSScanner *scanner = [NSScanner scannerWithString:addrHead];
        [scanner scanHexInt:&addrHex];

        unsigned addr0 = (addrHex & 0xFF00) >> 8;
        unsigned addr1 = (addrHex & 0xFF);

        addrHex = 0;
        scanner = [NSScanner scannerWithString:addrTail];
        [scanner scanHexInt:&addrHex];

        unsigned addr2 = (addrHex & 0xFF00) >> 8;
        unsigned addr3 = (addrHex & 0xFF);

        NSString *IPv4 = [[NSString alloc] initWithFormat:@"%d.%d.%d.%d", addr0, addr1, addr2, addr3];
        return IPv4.UTF8String;
    }
    return NULL;
}

#ifdef DEBUG
- (void)postLog:(NSString *)domain
           subURL:(NSString *)subURL
          request:(NSDictionary *)request
         response:(NSDictionary *)response
            error:(NSString *)errorStr
    realTimeLogID:(NSString *)realTimeLogID {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *timeStr = [UCARMonitorStore getTimeString];
    //只能支持平层，不支持嵌套
    NSDictionary *log = @{
        @"domain" : domain,
        @"subURL" : subURL,
        @"request" : [UCARMonitorStore stringFromJSONObject:request],
        @"response" : [UCARMonitorStore stringFromJSONObject:response],
        @"error" : errorStr,
        @"timestamp" : @(time),
        @"time" : timeStr,
        @"mobile" : realTimeLogID,
        @"uuid" : [NSUUID UUID].UUIDString
    };

    UCARHttpBaseConfig *config = [UCARHttpBaseConfig defaultConfig];
    config.domain = @"10.101.44.111:8090";
    config.subURL = @"/log";
    config.httpMethod = UCARHttpMethodPost;
    config.httpdnsEnable = NO;
    config.httpsEnable = NO;
    config.parameters = log;

    [self asyncHttpWithConfig:config
                      success:^(id _Nonnull response, NSDictionary *_Nullable request) {
                          //
                      }
                      failure:^(id _Nullable response, NSDictionary *_Nullable request, NSError *_Nonnull error){
                          //
                      }];
}
#endif

@end
