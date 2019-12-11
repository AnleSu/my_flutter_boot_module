//
//  UCARWXApi.h
//  UCARPlatform
//
//  Created  by hong.zhu on 2019/2/11.
//  Copyright © 2019年 UCar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCARWXApiDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCARWXApi : NSObject

/** 获取对象 */
+ (instancetype)wxApiWithDelegate:(id<UCARWXApiDelegate>)delegate;

/*! @brief WXApi的成员函数，向微信终端程序注册第三方应用。
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL)registerApp:(NSString *)appid;

/**
 是否安装微信
 */
+ (BOOL)isWXAppInstalled;
/**
 是否支持 Api
 */
+ (BOOL)isWXAppSupportApi;

/**
 调取微信支付(租车)
 
 @param infoDict 参数信息
 @return 是否调取成功
 */
- (BOOL)sendReqWithInfoDict:(NSDictionary *)infoDict;

#pragma mark -
#pragma mark - handleOpenURL
- (BOOL)handleOpenURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
