//
//  UCARSDKSetupTools.m
//  UCARApp
//
//  Created  by hong.zhu on 2019/2/26.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import "UCARSDKSetupTools.h"
#import "NSObject+UCARMethod.h"

@interface UCARSDKSetupTools ()

/**
 类型
 */
@property (nonatomic, weak, readonly) Class clazz;

@end

@implementation UCARSDKSetupTools

// 通过 clazz 获取一个对应的实例
+ (instancetype)setupToolsWithClazz:(Class)clazz {
    UCARSDKSetupTools *setupTools = [self new];
    setupTools->_clazz = clazz;
    return setupTools;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

// 设置新浪微博应用信息
- (void)UCARSDKSetupSinaWeiboByAppKey:(NSString *)appKey
                          redirectUri:(NSString *)redirectUri {
    Class clazz = self.clazz;
    SEL sel = @selector(registerWithAppID:redirectURI:);
    if (clazz && [clazz respondsToSelector:sel]) {
        [clazz ucarmethod_executeMethod:sel params:@[appKey, redirectUri]];
    }
}

// 设置QQ分享平台（QQ空间，QQ好友分享）应用信息
- (void)UCARSDKSetupQQByAppId:(NSString *)appId {
    [self p_UCARSDKSetupByAppId:appId];
}

// 设置微信(微信好友，微信朋友圈、微信收藏)应用信息
- (void)UCARSDKSetupWeChatByAppId:(NSString *)appId {
    [self p_UCARSDKSetupByAppId:appId];
}

- (void)p_UCARSDKSetupByAppId:(NSString *)appId {
    Class clazz = self.clazz;
    SEL sel = @selector(registerWithAppID:);
    if (clazz && [clazz respondsToSelector:sel]) {
        [clazz ucarmethod_executeMethod:sel params:@[appId]];
    }
}


#pragma clang diagnostic pop

@end
