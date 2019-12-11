//
//  UCARCMTransitHttpClient.m
//  CMT
//
//  Created  by hong.zhu on 2019/3/6.
//  Copyright © 2019年 linux. All rights reserved.
//

#import "UCARCMTransitHttpClient.h"

static NSString *const UCARTransitSessionID = @"UCARTransitSessionID";
static NSString *const UCARTransitAPISecretKey = @"UCARTransitAPISecretKey";
static NSString *const UCARTransitAPISecretKeyPlainText = @"UCARTransitAPISecretKeyPlainText";
static NSString *const UCARTransitAPISecretKeyEncrypted = @"UCARTransitAPISecretKeyEncrypted";

// 静态密钥
static NSString *const UCARCMTStaticAPISecretKey = @"Dgk6mhuR10DobkwfKBLo";

@implementation UCARCMTransitHttpClient

// 单例
+ (instancetype)sharedClient {
    static UCARCMTransitHttpClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[UCARCMTransitHttpClient alloc] init];
    });
    return client;
}

// 重写
- (void)commonInit {
    
    self.storeUserDefaults = [NSUserDefaults standardUserDefaults];
    
    self.sessionIDStoreKey = UCARTransitSessionID;
    self.APISecretKeyStoreKey = UCARTransitAPISecretKey;
    self.APISecretKeyEncryptedStoreKey = UCARTransitAPISecretKeyEncrypted;
    self.APISecretKeyPlainTextStoreKey = UCARTransitAPISecretKeyPlainText;
    self.staticAPISecretKey = UCARCMTStaticAPISecretKey;
    
    // domainInfoStoreKey  DomainInfo 不用处理
    
    [super commonInit];
}

//// 添加 proxy
//- (NSURLSessionDataTask *)asyncHttpWithConfig:(UCARMAPIHttpConfig *)config success:(UCARHttpSuccessBlock)successBlock failure:(UCARHttpFailureBlock)failureBlock {
//    if (![config.subURL hasPrefix:@"/ucarincapiproxy"]) {
//        config.subURL = [NSString stringWithFormat:@"/ucarincapiproxy%@", config.subURL];
//    }
//
//    return [super asyncHttpWithConfig:config success:successBlock failure:failureBlock];
//}

@end
