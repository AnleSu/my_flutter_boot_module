//
//  UCARWXApiDelegate.h
//  UCARPlatform
//
//  Created  by hong.zhu on 2019/2/11.
//  Copyright © 2019年 UCar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UCARWXApi;

/*! @brief 错误码
 *
 */
typedef NS_ENUM(NSInteger, UCARWXCode) {
    UCARWXCodeSuccess         = 0,    /**< 成功    */
    UCARWXCodeErrorCommon     = -1,   /**< 普通错误类型    */
    UCARWXCodeErrorUserCancel = -2,   /**< 用户点击取消并返回    */
    UCARWXCodeErrorSentFail   = -3,   /**< 发送失败    */
    UCARWXCodeErrorAuthDeny   = -4,   /**< 授权失败    */
    UCARWXCodeErrorUnsupport  = -5,   /**< 微信不支持    */
};

NS_ASSUME_NONNULL_BEGIN

@protocol UCARWXApiDelegate <NSObject>

/**
 支付回调
 */
- (void)wxApi:(UCARWXApi*)wxApi code:(UCARWXCode)code message:(NSString*)message;

@end

NS_ASSUME_NONNULL_END
