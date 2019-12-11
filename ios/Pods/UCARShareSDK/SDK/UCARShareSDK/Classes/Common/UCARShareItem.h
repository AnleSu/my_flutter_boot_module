//
//  UCARShareItem.h
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UCARShareConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCARShareItem : NSObject

/**
 通过 shareType 创建对应实例
 */
+ (instancetype)itemWithShareType:(UCARShareType)shareType;

/**
 分享渠道
 @note 如果是: UCARShareTypeSina, exInfo的值,必须有效
 */
@property (nonatomic, assign, readonly) UCARShareType shareType;
/**
 objectID 微博专用
 */
@property (nonatomic, copy) NSString* objectID;

/**
 分享标题
 */
@property (nonatomic, copy) NSString* title;
/**
 分享摘要
 */
@property (nonatomic, copy) NSString* summary;

/**
  是否为纯文本
 */
@property (nonatomic, assign) BOOL bText;

/** 缩略图 */
@property (nonatomic, copy) NSString* thumbnaiURL;

/**
 小程序分享缩略图
 */
@property (nonatomic, strong) NSData* miniProgramhHDImageData;

/**
 是否使用带shareTicket的分享
 */
@property (nonatomic, assign) BOOL withShareTicket;


/**
 链接
 */
@property (nonatomic, copy) NSString* webpageUrl;

/**
 图片分享
 
 @note 大小不能超过25M   在 QQ 分享时与 `forceCallPreviewImageData` 属性互斥, 当 forceCallPreviewImageData == NO 时, imageData 有值则为 QQ 纯图片分享
 */
@property (nonatomic, strong) NSData *imageData;

/**
 直接使用 +[QQApiNewsObject objectWithURL: title: description: previewImageData:] 进行分享调用
 */
@property (nonatomic, assign) BOOL forceCallPreviewImageData;

/**
 分享小程序类型
 */
@property (nonatomic, assign) UCARWXMiniProgramType ucar_miniProgramType;

#pragma mark -
#pragma mark - 以下为短信专用
/** 短信 */
@property (nonatomic, copy) NSString* sms;
/** 短信收件人 手机号码 */
@property (nonatomic, strong) NSArray<NSString*>* recipients;
/** 短信控制器的弹出样式  默认 UIModalPresentationFullScreen  */
@property (nonatomic, assign) UIModalPresentationStyle modalPresentationStyle;

/**
 当前控制器
 @note 用于短信
 */
@property (nonatomic, weak) UIViewController* curController;

#pragma mark -
#pragma mark - 微信小程序专用
/**
 小程序的应用 id
 */
@property (nonatomic, copy) NSString *userName;

/** 小程序页面的路径
 * @attention 不填默认拉起小程序首页
 */
@property (nonatomic, copy, nullable) NSString *path;

#pragma mark -
#pragma mark - pdf 文件
/**
 文档数据
 */
@property (nonatomic, strong) NSData *fileData;
/**
文件后缀
 */
@property (nonatomic, copy) NSString *fileExtension;
/**
 缩略图
 
 @note 大小不能超过64K
 */
@property (nonatomic, strong) UIImage *thumbImage;

/**
 新浪正在 auth 操作
 */
@property (nonatomic, assign) BOOL sinaAuth;

/**
 RedirectURI
 */
@property (nonatomic, copy) NSString *sinaRedirectURI;

/**
 access_token
 */
@property (nonatomic, copy) NSString *access_token;

@end

NS_ASSUME_NONNULL_END
