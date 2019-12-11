//
//  UCARCMTZCHttpClient.m
//  CMT
//
//  Created by hong.zhu on 2018/8/8.
//  Copyright © 2018年 linux. All rights reserved.
//

#import "UCARCMTZCHttpClient.h"

static NSString *const UserDefaultKeyUCARCMTZCDomainInfo = @"UCARCMTZCDomainInfo";

// 静态密钥
// static NSString *const UCARCMTZCStaticAPISecretKey = @"qjKKlZzDjTTX5ZhOV5HZ";

@implementation UCARCMTZCHttpClient

// 单例
+ (instancetype)sharedClient {
    static UCARCMTZCHttpClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[UCARCMTZCHttpClient alloc] init];
    });
    return client;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDomainInfoWithGroupStoreKey:UserDefaultKeyUCARCMTZCDomainInfo];
    }
    return self;
}

@end
