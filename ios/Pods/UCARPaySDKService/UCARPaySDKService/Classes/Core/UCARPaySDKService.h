//
//  UCARPaySDKService.h
//  UCARPlatform
//
//  Created  by hong.zhu on 2019/2/15.
//  Copyright © 2019年 UCar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCARPaySDKDelegate.h"

@class UCARPaySDKRequestModel;

NS_ASSUME_NONNULL_BEGIN

@interface UCARPaySDKService : NSObject

/**
 通过 delegate 创建实例
 */
+ (instancetype)paySDKServiceWithDelegate:(id<UCARPaySDKDelegate>)delegate;

#pragma mark -
#pragma mark - 云闪付
/**
 调用支付的app注册在info.plist中的scheme
 */
@property (nonatomic, copy) NSString* unionScheme;
/**
 支付环境
 */
@property (nonatomic, copy) NSString* unionMode;

#pragma mark -
#pragma mark - Apple Pay
@property (nonatomic, copy) NSString *applePayMerchantId;

#pragma mark -
#pragma mark - 支付宝
@property (nonatomic, copy) NSString* aliPayScheme;

#pragma mark -
#pragma mark - 微信
/**
 注册微信
 */
+ (void)registerActiveWX:(NSString *)appid;

/**
 是否安装了对应支付方式的 APP
 
 @note 目前支持 微信 | 支付宝 | 云闪付
 */
+ (BOOL)installedAppWithPaySDKType:(UCARPaySDKType)paySDKType;

/**
 是否支持 Api
 */
+ (BOOL)isWXAppSupportApi;

/**
 发起支付
 */
- (BOOL)paySDKWithRequestModel:(UCARPaySDKRequestModel *)requestModel;

#pragma mark -
#pragma mark - handleOpenURL
- (BOOL)handleOpenURL:(NSURL *)url paySDKType:(UCARPaySDKType)paySDKType;

@end

NS_ASSUME_NONNULL_END
