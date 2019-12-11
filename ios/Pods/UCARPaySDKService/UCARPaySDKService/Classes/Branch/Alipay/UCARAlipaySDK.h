//
//  UCARAlipaySDK.h
//  UCARPlatform
//
//  Created  by hong.zhu on 2019/2/11.
//  Copyright © 2019年 UCar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCARAlipaySDKDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 支付宝
 */
@interface UCARAlipaySDK : NSObject

/** 获取对象 */
+ (instancetype)alipaySDKWithScheme:(NSString*)scheme delegate:(id<UCARAlipaySDKDelegate>)delegate;

/**
 *  支付接口
 *
 *  @param orderStr       订单信息
 */
- (void)payOrder:(NSString *)orderStr;

#pragma mark -
#pragma mark - handleOpenURL
- (BOOL)handleOpenURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
