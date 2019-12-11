//
//  UCARAlipaySDKDelegate.h
//  UCARPlatform
//
//  Created  by hong.zhu on 2019/2/11.
//  Copyright © 2019年 UCar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UCARAlipaySDK;


/**
 支付结果状态

 - UCARAlipaySDKStatusSuccess: 成功
 - UCARAlipaySDKStatusFailure: 失败
 */
typedef NS_ENUM(NSInteger, UCARAlipaySDKStatus) {
    UCARAlipaySDKStatusSuccess,
    UCARAlipaySDKStatusFailure
};

NS_ASSUME_NONNULL_BEGIN

@protocol UCARAlipaySDKDelegate <NSObject>

- (void)alipaySDK:(UCARAlipaySDK*)alipaySDK status:(UCARAlipaySDKStatus)status resultDic:(NSDictionary*)resultDic;

@end

NS_ASSUME_NONNULL_END
