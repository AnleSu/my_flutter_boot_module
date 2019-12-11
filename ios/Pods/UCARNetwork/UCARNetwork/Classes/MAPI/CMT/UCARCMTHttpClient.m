//
//  UCARCMTHttpClient.m
//  CMT
//
//  Created by hong.zhu on 2018/8/8.
//  Copyright © 2018年 linux. All rights reserved.
//

#import "UCARCMTHttpClient.h"

static NSString *const UserDefaultKeyUCARCMTDomainInfo = @"UCARCMTDomainInfo";

@implementation UCARCMTHttpClient

// 单例
+ (instancetype)sharedClient {
    static UCARCMTHttpClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[UCARCMTHttpClient alloc] init];
    });
    return client;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDomainInfoWithGroupStoreKey:UserDefaultKeyUCARCMTDomainInfo];
    }
    return self;
}

- (void)refreshKey:(BOOL)init {
    UCARMAPIHttpConfig *config = [UCARMAPIHttpConfig defaultConfig];
    config.subURL = UCARURLPCARRefreshKey;
    config.domain = self.APIDomain;
    config.cid = self.cid;
    [[UCARCMTransitHttpClient sharedClient] refreshKeyWithConfig:config];
}

@end
