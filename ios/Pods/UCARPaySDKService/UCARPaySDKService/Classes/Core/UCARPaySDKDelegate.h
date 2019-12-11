//
//  UCARPaySDKDelegate.h
//  UCARPlatform
//
//  Created  by hong.zhu on 2019/2/15.
//  Copyright © 2019年 UCar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCARPayConstConfiguration.h"

@class UCARPaySDKService;

NS_ASSUME_NONNULL_BEGIN

@protocol UCARPaySDKDelegate <NSObject>

@optional
// Paypal 支付完成, 向服务器请求支付结果
- (void)paypalSDKService:(UCARPaySDKService *)paySDKService completedForParams:(nonnull NSDictionary *)params controller:(nonnull UIViewController *)paymentViewController;
// Paypal 交易取消
- (void)didCancelWithPaypalSDKService:(UCARPaySDKService *)paySDKService;

// 云闪付
- (void)unionPaySDKService:(UCARPaySDKService *)paySDKService resultStatus:(UCARUNIONSDKResultStatus)resultStatus;
// Apple Pay
- (void)applePaySDKService:(UCARPaySDKService *)paySDKService resultStatus:(UCARSDKPaymentResultStatus)resultStatus message:(NSString *)message;
// 支付宝
- (void)aliPaySDKService:(UCARPaySDKService *)paySDKService status:(UCARSDKAlipaySDKStatus)status resultDic:(NSDictionary *)resultDic;
// 微信
- (void)wxPaySDKService:(UCARPaySDKService *)paySDKService code:(UCARPaySDKWXCode)code message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
