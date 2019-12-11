//
//  UCARCMTransitHttpManager.m
//  CMT
//
//  Created  by hong.zhu on 2019/3/6.
//  Copyright © 2019年 linux. All rights reserved.
//

#import "UCARCMTransitHttpManager.h"
#import "UCARHttpBaseManager.h"
#import <UCARUtility/UCARUtility.h>

@implementation UCARCMTransitHttpManager

- (void)initDomainInfoWithGroupStoreKey:(NSString *)groupStoreKey {
    NSString *configPath = [[UCARHttpBaseManager sharedManager] pathForResource:@"ucarhttpconfig" ofType:@"plist"];
    NSDictionary *httpConfig = [NSDictionary dictionaryWithContentsOfFile:configPath];
    NSString *envKey = [UCAREnvConfig getCurrentEnvKey];
    NSDictionary *currentConfig = httpConfig[envKey];
    NSDictionary *domainInfo = currentConfig[groupStoreKey];
    //获取域名
    _APIDomain = domainInfo[@"domain"];
    
    NSString *MAPIIP = domainInfo[@"ip"];
    [[UCARHttpBaseManager sharedManager] setDomain:_APIDomain andIP:MAPIIP];
}

- (NSURLSessionDataTask *)asyncHttpWithConfig:(UCARMAPIHttpConfig *)config
                                      success:(UCARHttpSuccessBlock)successBlock
                                      failure:(UCARHttpFailureBlock)failureBlock {
    config.domain = self.APIDomain;
    config.cid = self.cid;
    
    return [[UCARCMTransitHttpClient sharedClient] asyncHttpWithConfig:config success:successBlock failure:failureBlock];
}

- (void)refreshKey:(BOOL)init {
    UCARLoggerDebug(@"error, child must implement refreshKey");
}

@end
