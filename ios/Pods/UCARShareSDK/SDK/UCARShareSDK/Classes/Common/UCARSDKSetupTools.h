//
//  UCARSDKSetupTools.h
//  UCARApp
//
//  Created  by hong.zhu on 2019/2/26.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UCARSDKSetupTools : NSObject

/**
 通过 clazz 获取一个对应的实例
 */
+ (instancetype)setupToolsWithClazz:(Class)clazz;

/**
 *  设置新浪微博应用信息
 *
 *  @param appKey       应用标识
 *  @param redirectUri  回调地址
 */
- (void)UCARSDKSetupSinaWeiboByAppKey:(NSString *)appKey
                          redirectUri:(NSString *)redirectUri;

/**
 *  设置QQ分享平台（QQ空间，QQ好友分享）应用信息
 *
 *  @param appId          应用标识
 */
- (void)UCARSDKSetupQQByAppId:(NSString *)appId;

/**
 *  设置微信(微信好友，微信朋友圈、微信收藏)应用信息
 *
 *  @param appId      应用标识
 */
- (void)UCARSDKSetupWeChatByAppId:(NSString *)appId;


@end

NS_ASSUME_NONNULL_END
