//
//  UCARShareWX.m
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import "UCARShareWX.h"
#import "WXApi.h"
#import "UCARShareWXDelegate.h"
#import "UCARShareItem.h"
#import "SendMessageToWXReq+requestWithTextOrMediaMessage.h"
#import "WXMediaMessage+messageConstruct.h"

/**
 记录 AppID
 */
static NSString * _kWXAppId = @"";

@interface UCARShareWX () <WXApiDelegate>

@end

@implementation UCARShareWX

// 注册
+ (NSString*)registerWithAppID:(NSString*)appID {
    // 赋值
    _kWXAppId = appID;
    // 注册
    BOOL registerWechat = [WXApi registerApp:appID];
    if (registerWechat) {
        return nil;
    }
    return @"微信未注册成功";
}

// 是否安装微信客户端
+ (BOOL)isAppInstalled {
    return [WXApi isWXAppInstalled];
}

// 发起分享
- (NSString *)shareWithItem:(UCARShareItem *)item {
    
    __weak typeof(self) weakSelf = self;
    // 数据检查
    BaseReq* messageToWXReq = [self messageReqWithItem:item completed:^(SendMessageToWXReq *msgToWXReq) {
        // 微信分享
        [weakSelf sendMessageToWXReq:msgToWXReq];
    }];
    
    if (!messageToWXReq) {
        return @"微信打开分享";
    }
    
    // 微信分享
    return [self sendMessageToWXReq:messageToWXReq];
}

// 微信分享
- (NSString*)sendMessageToWXReq:(BaseReq*)messageToWXReq {
    BOOL toWXReq = [WXApi sendReq:messageToWXReq];
    if (toWXReq) {
        return nil;
    }
    
    return @"微信打开分享";
}


// 分享数据体
- (BaseReq*)messageReqWithItem:(UCARShareItem*)shareItem completed:(void (^)(SendMessageToWXReq* messageToWXReq))completed {
    switch (shareItem.shareType) {
        case UCARShareTypeWeChatSession:
        case UCARShareTypeWechatTimeline:
            return [self messageToWXReqWithItem:shareItem completed:completed];
        case UCARShareTypeMiniProgram:
            // 分享小程序
            return [self messageToMiniProgramReqWithItem:shareItem];
            break;
        case UCARShareTypeOpenMiniProgram:
            // 打开小程需
            return [self messageOpenMiniProgramReqWithItem:shareItem];
            break;
            
            
        default:
            break;
    }
    
    return nil;
}

- (BaseReq*)messageOpenMiniProgramReqWithItem:(UCARShareItem*)shareItem  {
    WXLaunchMiniProgramReq *launchMiniProgramReq = [WXLaunchMiniProgramReq object];
    launchMiniProgramReq.userName = shareItem.userName;  //拉起的小程序的username
    launchMiniProgramReq.path = shareItem.path;    //拉起小程序页面的可带参路径，不填默认拉起小程序首页
    launchMiniProgramReq.miniProgramType = [self miniProgramTypeWithMiniProgramType:shareItem.ucar_miniProgramType];; //拉起小程序的类型
    return launchMiniProgramReq;
}

// 类型转换: UCARWXMiniProgramType ---> WXMiniProgramType
- (WXMiniProgramType)miniProgramTypeWithMiniProgramType:(UCARWXMiniProgramType)ucar_miniProgramType {
    WXMiniProgramType miniProgramType = WXMiniProgramTypeRelease;
    switch (ucar_miniProgramType) {
        case UCARWXMiniProgramTypeTest:
            miniProgramType = WXMiniProgramTypeTest;
            break;
        case UCARWXMiniProgramTypePreview:
            miniProgramType = WXMiniProgramTypePreview;
            break;
        default:
            break;
    }
    
    return miniProgramType;
}

// 分享
- (BaseReq*)messageToMiniProgramReqWithItem:(UCARShareItem*)shareItem  {
    WXMiniProgramObject *object = [WXMiniProgramObject object];
    object.webpageUrl = shareItem.webpageUrl;
    object.userName = shareItem.userName;
    object.path = shareItem.path;
    object.hdImageData = shareItem.miniProgramhHDImageData;
    object.withShareTicket = shareItem.withShareTicket;
    object.miniProgramType = [self miniProgramTypeWithMiniProgramType:shareItem.ucar_miniProgramType];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = shareItem.title;
    message.description = shareItem.summary;
    message.thumbData = nil;  //兼容旧版本节点的图片，小于32KB，新版本优先
    // 使用WXMiniProgramObject的hdImageData属性
    message.mediaObject = object;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;  // 目前只支持会话
    
    return req;
}

// 分享到好友或者朋友圈 数据体
- (SendMessageToWXReq*)messageToWXReqWithItem:(UCARShareItem*)shareItem completed:(void (^)(SendMessageToWXReq* messageToWXReq))completed {
    if (shareItem.bText) {
        // 纯文本
        return [self textToWXReqWithItem:shareItem];
    }
    
    if (shareItem.fileData) {
        // 文件
        return [self fileToWXReqWithItem:shareItem];
    }
    
    if (shareItem.imageData) {
        // 图片分享
        return [self imageToWXReqWithItem:shareItem];
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = shareItem.title?shareItem.title:shareItem.summary;
    message.description = shareItem.summary;
    
    if (shareItem.thumbnaiURL) {
        if (!completed) {
            return nil;
        }
        [self loadImageWithURLSrtring:shareItem.thumbnaiURL completed:^(UIImage * _Nullable image, NSData * _Nullable data) {
            NSData* thumbnailData = nil;
            if (image) {
                // 大小不能超过32K
                thumbnailData = [self imageCompressWithMaxLength:32*1024 image:image];
            }
            
            if (thumbnailData) {
                [message setThumbData:thumbnailData];
            }
            
            completed([self createMediaMessage:message shareItem:shareItem]);
        }];
        
        // 异步获取图片, 直接返回
        return nil;
    }
    
    return [self createMediaMessage:message shareItem:shareItem];
}

// 创建 SendMessageToWXReq
- (SendMessageToWXReq*)createMediaMessage:(WXMediaMessage*)message shareItem:(UCARShareItem*)shareItem {
    if (shareItem.thumbImage) {
        [message setThumbImage:shareItem.thumbImage];
    }
    
    // 多媒体消息中包含的网页数据对象
    if (shareItem.webpageUrl) {
        WXWebpageObject *webpageObject = [WXWebpageObject object];
        // 网页的url地址
        webpageObject.webpageUrl = shareItem.webpageUrl;
        message.mediaObject = webpageObject;
    }
    
    SendMessageToWXReq* msgToWXReq = [[SendMessageToWXReq alloc] init];
    msgToWXReq.bText = NO;
    msgToWXReq.message = message;
    
    if (shareItem.shareType == UCARShareTypeWeChatSession) {
        msgToWXReq.scene = WXSceneSession;
    } else {
        msgToWXReq.scene = WXSceneTimeline;
    }
    
    return msgToWXReq;
}

// 纯文本
- (SendMessageToWXReq*)textToWXReqWithItem:(UCARShareItem*)shareItem {
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = shareItem.summary;
    req.bText = shareItem.bText;
    
    if (shareItem.shareType == UCARShareTypeWeChatSession) {
        req.scene = WXSceneSession;
    } else {
        req.scene = WXSceneTimeline;
    }
    return req;
}

// 文件数据体
- (SendMessageToWXReq*)fileToWXReqWithItem:(UCARShareItem*)shareItem {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = shareItem.title;
    message.description = shareItem.summary;
    [message setThumbImage:shareItem.thumbImage];
    
    WXFileObject *ext = [WXFileObject object];
    ext.fileExtension = shareItem.fileExtension;
    ext.fileData = shareItem.fileData;
    
    message.mediaObject = ext;
    
    int scene;
    if (shareItem.shareType == UCARShareTypeWeChatSession) {
        scene = WXSceneSession;
    } else {
        scene = WXSceneTimeline;
    }
    
    SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil OrMediaMessage:message bText:NO InScene:scene];
    return req;
}

// 图片数据体
- (SendMessageToWXReq*)imageToWXReqWithItem:(UCARShareItem*)shareItem {
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = shareItem.imageData;
    
    NSString *action = @"<action>dotalist</action>";
    action = @"";
    NSString *tagName = @"WECHAT_TAG_JUMP_APP";
    tagName = @"";
    
    int scene;
    if (shareItem.shareType == UCARShareTypeWeChatSession) {
        scene = WXSceneSession;
    } else {
        scene = WXSceneTimeline;
    }
    
    WXMediaMessage *message = [WXMediaMessage messageWithTitle:nil
                                                   Description:nil
                                                        Object:ext
                                                    MessageExt:shareItem.summary
                                                 MessageAction:action
                                                    ThumbImage:shareItem.thumbImage
                                                      MediaTag:tagName];
    
    SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    return req;
}

#pragma mark -
#pragma mark - App 之间的回调
- (void)handleOpenURL:(NSURL *)url {
    // wxc137d1aeefebdce2://platformId=wechat
    NSString *scheme = url.scheme;
    if (!scheme || (scheme.length ==0)) {
        return;
    }
    
    if (!_kWXAppId || (_kWXAppId.length == 0)) {
        return;
    }
    
    if (![scheme isEqualToString:_kWXAppId]) {
        return;
    }
    
    if ([url.host isEqualToString:@"pay"]) {
        // 是微信支付的话, 需要返回, 不处理
        return;
    }
    
    [WXApi handleOpenURL:url delegate:(id<WXApiDelegate>)self];
}

#pragma mark -
#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    // 支付 不走这个逻辑
    if ([resp isKindOfClass:[PayResp class]]) {
        return;
    }
    
    int errCode = resp.errCode;
    NSString* errStr = resp.errStr;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareWX:result:message:)]) {
        [self.delegate shareWX:self result:errCode message:errStr];
    }
}

@end
