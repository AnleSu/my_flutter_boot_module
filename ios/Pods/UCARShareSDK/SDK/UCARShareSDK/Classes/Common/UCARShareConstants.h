//
//  UCARShareConstants.h
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCARSDKSetupTools.h"

/** 分享渠道 */
typedef NS_ENUM(NSInteger, UCARShareType) {
    /** 未知 */
    UCARShareTypeNone,
    /** 微信聊天 */
    UCARShareTypeWeChatSession,
    /** 朋友圈 */
    UCARShareTypeWechatTimeline,
    /** 分享微信小程序内容 */
    UCARShareTypeMiniProgram,
    /** 打开微信小程序 */
    UCARShareTypeOpenMiniProgram,
    /** QQ 聊天 */
    UCARShareTypeQQSession,
    /** QQ 空间 */
    UCARShareTypeQQZone,
    /** 新浪 */
    UCARShareTypeSina,
    /** 短信 */
    UCARShareTypeSMS
};

/**
 SMS 发送结果回调
 */
typedef NS_ENUM(NSInteger, UCARMessageComposeResult) {
    UCARMessageComposeResultCancelled,
    UCARMessageComposeResultSent,
    UCARMessageComposeResultFailed
};

/**
 Weibo 发送结果回调
 */
typedef NS_ENUM(NSInteger, UCARWeiboSDKResponseStatusCode)
{
    UCARWeiboSDKResponseStatusCodeSuccess               = 0,//成功
    UCARWeiboSDKResponseStatusCodeUserCancel            = -1,//用户取消发送
    UCARWeiboSDKResponseStatusCodeSentFail              = -2,//发送失败
    UCARWeiboSDKResponseStatusCodeAuthDeny              = -3,//授权失败
    UCARWeiboSDKResponseStatusCodeUserCancelInstall     = -4,//用户取消安装微博客户端
    UCARWeiboSDKResponseStatusCodePayFail               = -5,//支付失败
    UCARWeiboSDKResponseStatusCodeShareInSDKFailed      = -8,//分享失败 详情见response UserInfo
    UCARWeiboSDKResponseStatusCodeUnsupport             = -99,//不支持的请求
    UCARWeiboSDKResponseStatusCodeUnknown               = -100,
};

/**
 WX 发送结果回调
 */
typedef NS_ENUM(NSInteger, UCARWXErrCode) {
    UCARWXSuccess           = 0,
    UCARWXErrCodeCommon     = -1,
    UCARWXErrCodeUserCancel = -2,
    UCARWXErrCodeSentFail   = -3,
    UCARWXErrCodeAuthDeny   = -4,
    UCARWXErrCodeUnsupport  = -5,
};

/*! @brief 分享小程序类型
 *
 */
typedef NS_ENUM(NSUInteger, UCARWXMiniProgramType) {
    UCARWXMiniProgramTypeRelease = 0,       //**< 正式版  */
    UCARWXMiniProgramTypeTest = 1,        //**< 开发版  */
    UCARWXMiniProgramTypePreview = 2,         //**< 体验版  */
};

/**
 QQ 发送结果回调
 */
typedef NS_ENUM(NSInteger, UCARQQErrCode) {
    UCARQQSuccess = 0,
    UCARQQErrFail = 1,
    UCARQQErrCancel = -4,
};

// 结果状态返回
typedef NS_ENUM(NSInteger, UCARShareSDKResult) {
    UCARShareSDKResultSuccess,
    UCARShareSDKResultFail,
    UCARShareSDKResultCancel
};

/**
 *  配置分享平台回调处理器
 *
 *  @param shareType 需要初始化的分享平台类型
 *  @param setupTools      需要初始化的分享平台应用信息
 */
typedef void(^UCARKConfigurationHandler) (UCARShareType shareType, UCARSDKSetupTools *setupTools);

// 通知
FOUNDATION_EXTERN NSString * const UCARDMethodHOpenURLNotification;

/**
NS_ASSUME_NONNULL_BEGIN

@interface UCARShareConstants : NSObject

@end

NS_ASSUME_NONNULL_END
 */
