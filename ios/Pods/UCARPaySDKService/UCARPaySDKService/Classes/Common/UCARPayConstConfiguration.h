//
//  UCARPayConstConfiguration.h
//  UCARPlatform
//
//  Created  by hong.zhu on 2019/2/15.
//  Copyright © 2019年 UCar. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 SDK 支付防方式
 
 - UCARPaySDKTypeUnkown: 未知
 - UCARPaySDKTypePaypal:  PayPal
 - UCARPaySDKTypeUnion:  云闪付
 - UCARPaySDKTypeApplePay: 苹果支付
 - UCARPaySDKTypeAliPay: 支付宝
 - UCARPaySDKTypeWX: 微信
 */
typedef NS_ENUM(NSInteger, UCARPaySDKType) {
    UCARPaySDKTypeUnkown,
    UCARPaySDKTypePaypal,
    UCARPaySDKTypeUnion,
    UCARPaySDKTypeApplePay,
    UCARPaySDKTypeAliPay,
    UCARPaySDKTypeWX
};

/**
 云闪付支付结果状态
 
 - UCARUNIONSDKResultStatusSuccess: 成功
 - UCARUNIONSDKResultStatusFailure: 失败
 */
typedef NS_ENUM(NSInteger, UCARUNIONSDKResultStatus) {
    UCARUNIONSDKResultStatusSuccess,
    UCARUNIONSDKResultStatusFailure
};

/**
 Apple Pay 支付结果
 */
typedef NS_ENUM(NSInteger, UCARSDKPaymentResultStatus) {
    UCARSDKPaymentResultStatusSuccess,        //支付成功
    UCARSDKPaymentResultStatusFailure,        //支付失败
    UCARSDKPaymentResultStatusCancel,         //支付取消
    UCARSDKPaymentResultStatusUnknownCancel   //支付取消，交易已发起，状态不确定，商户需查询商户后台确认支付状态
};

/**
 支付宝支付结果状态
 
 - UCARSDKAlipaySDKStatusSuccess: 成功
 - UCARSDKAlipaySDKStatusFailure: 失败
 */
typedef NS_ENUM(NSInteger, UCARSDKAlipaySDKStatus) {
    UCARSDKAlipaySDKStatusSuccess,
    UCARSDKAlipaySDKStatusFailure
};

/*! @brief 微信错误码
 *
 */
typedef NS_ENUM(NSInteger, UCARPaySDKWXCode) {
    UCARPaySDKWXCodeSuccess         = 0,    /**< 成功    */
    UCARPaySDKWXCodeErrorCommon     = -1,   /**< 普通错误类型    */
    UCARPaySDKWXCodeErrorUserCancel = -2,   /**< 用户点击取消并返回    */
    UCARPaySDKWXCodeErrorSentFail   = -3,   /**< 发送失败    */
    UCARPaySDKWXCodeErrorAuthDeny   = -4,   /**< 授权失败    */
    UCARPaySDKWXCodeErrorUnsupport  = -5,   /**< 微信不支持    */
};

//NS_ASSUME_NONNULL_BEGIN
//
//@interface UCARPayConstConfiguration : NSObject
//
//@end
//
//NS_ASSUME_NONNULL_END
