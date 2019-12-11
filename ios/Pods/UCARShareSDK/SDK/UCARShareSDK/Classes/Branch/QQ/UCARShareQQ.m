//
//  UCARShareQQ.m
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import "UCARShareQQ.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "UCARShareQQDelegate.h"
#import "UCARShareItem.h"
#import <UCARLogger/UCARLogger.h>
#import <SDWebImage/SDWebImageManager.h>

@interface UCARShareQQ () <QQApiInterfaceDelegate>

@end

@implementation UCARShareQQ

// 注册
+ (NSString*)registerWithAppID:(NSString*)appID {
    // 注册
    id obj = [[TencentOAuth alloc] initWithAppId:appID andDelegate:nil];
    if (obj) {
        return nil;;
    }
    return @"注册失败";
}


// 是否安装 QQ 客户端
+ (BOOL)isAppInstalled {
    return [QQApiInterface isQQInstalled];
}

// 发起分享
- (NSString *)shareWithItem:(UCARShareItem *)item {
    // 开始分享
    SendMessageToQQReq* msgToQQReq = nil;
    if (item.forceCallPreviewImageData) {
        msgToQQReq = [self forceCallPreviewImageDataQQReqWithItem:item];
    } else {
        __weak typeof(self) weakSelf = self;
        
        // 需要下载图片的情况, 这里返回的是 nil, 实际以 completed 返回为准
        msgToQQReq = [self messageToQQReqWithItem:item completed:^(SendMessageToQQReq *messageToQQReq) {
            // 发送分享
            [weakSelf sendMessageToQQReq:messageToQQReq];
        }];
    }
    
    if (!msgToQQReq) {
        return @"发起 QQ 分享";
    }
    
    // 发送分享
    [self sendMessageToQQReq:msgToQQReq];
    
    // 结果
    return @"发起 QQ 分享";
}

// 发送分享
- (void)sendMessageToQQReq:(SendMessageToQQReq*)msgToQQReq {
    QQApiSendResultCode sent = [QQApiInterface sendReq:msgToQQReq];
    if (EQQAPISENDSUCESS == sent) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareQQ:result:message:)]) {
        // 1: 为失败
        [self.delegate shareQQ:self result:1 message:@"发起 QQ 分享失败"];
    }
}

// 直接使用 +[QQApiNewsObject objectWithURL: title: description: previewImageData:] 进行分享调用
- (SendMessageToQQReq*)forceCallPreviewImageDataQQReqWithItem:(UCARShareItem *)item {
    NSURL* webpageUrl = [NSURL URLWithString:item.webpageUrl];
    QQApiNewsObject* apiObject = [QQApiNewsObject objectWithURL:webpageUrl
                                                          title:item.title
                                                    description:item.summary
                                               previewImageData:item.imageData];
    
    SendMessageToQQReq* msgToQQReq = [SendMessageToQQReq reqWithContent:apiObject];;
    return msgToQQReq;
}

// 分享消息体
- (SendMessageToQQReq*)messageToQQReqWithItem:(UCARShareItem *)item completed:(void (^)(SendMessageToQQReq*))completed {
    NSURL* webpageUrl = [NSURL URLWithString:item.webpageUrl];
    QQApiObject *apiObject = nil;
    if(item.imageData.length > 0) {
        NSData* imageData = item.imageData;
        UIImage * image = [UIImage imageWithData:imageData];
        if (image) {
            NSData *data = [self imageCompressWithMaxLength:5*1024*1024 image:image];
            NSData *previewImageData = [self imageCompressWithMaxLength:1024*1024 image:image];
            apiObject = [QQApiImageObject objectWithData:data previewImageData:previewImageData title:@"" description:@"" imageDataArray:@[]];
        }
    } else {
        if ((item.summary.length == 0) && (item.title.length == 0) && (item.thumbnaiURL.length > 0)) {
            if (!completed) {
                return nil;
            }
            // thumbnaiURL 是一个图片链接
            [self loadImageWithURLSrtring:item.thumbnaiURL completed:^(UIImage * _Nullable image, NSData * _Nullable data) {
                if (image) {
                    NSData *compressData = [self imageCompressWithMaxLength:5*1024*1024 image:image];
                    NSData *previewImageData = [self imageCompressWithMaxLength:1024*1024 image:image];
                    
                    QQApiObject *apiImageObject = [QQApiImageObject objectWithData:compressData previewImageData:previewImageData title:@"" description:@"" imageDataArray:@[]];
                    completed([self createSendMessageToQQReqWithAIPObject:apiImageObject item:item]);
                }
            }];
            
            // 异步获取图片, 直接返回
            return nil;
        } else {
            if ((item.webpageUrl.length == 0) && (item.thumbnaiURL.length == 0)) {
                apiObject = [QQApiTextObject objectWithText:item.summary?item.summary:item.title];
            } else {
                apiObject = [QQApiNewsObject objectWithURL:webpageUrl title:item.title description:item.summary previewImageURL:[NSURL URLWithString:item.thumbnaiURL]];
            }
        }
    }
    return [self createSendMessageToQQReqWithAIPObject:apiObject item:item];
}

// 创建 消息体
- (SendMessageToQQReq*)createSendMessageToQQReqWithAIPObject:(QQApiObject*)apiObject item:(UCARShareItem *)item {
    SendMessageToQQReq* msgToQQReq = nil;
    if (apiObject) {
        uint64_t cflag = (item.shareType == UCARShareTypeQQSession)?0:1;
        [apiObject setCflag:cflag];
        msgToQQReq = [SendMessageToQQReq reqWithContent:apiObject];
    }
    
    return msgToQQReq;
}

// 回调
// QQ41CD2FE4://response_from_qq?error_description=dGhlIHVzZXIgZ2l2ZSB1cCB0aGUgY3VycmVudCBvcGVyYXRpb24=&source=qq&source_scheme=mqqapi&error=-4&version=1&sdkv=3.1
- (void)handleOpenURL:(NSURL*)url {
    NSString *host = url.host;
    if (!host || (host.length == 0)) {
        return;
    }
    
    if (![host isEqualToString:@"response_from_qq"]) {
        return;
    }
    
    // 设置代理
    [QQApiInterface handleOpenURL:url delegate:self];
    
    if (YES == [TencentOAuth CanHandleOpenURL:url]) {
        UCARLoggerDebug(@"%@", url.description);
        [TencentOAuth HandleOpenURL:url];
    }
}

#pragma mark -
#pragma mark - QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req {
    switch (req.type) {
        case EGETMESSAGEFROMQQREQTYPE:
        {   // 手Q -> 第三方应用，请求第三方应用向手Q发送消息
            // sdkDemoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            // appDelegate.isRequestFromQQ = YES;
            break;
        }
        default:
            break;
    }
}

// 处理QQ在线状态的回调
- (void)isOnlineResponse:(NSDictionary *)response {
    
}

// 代理回调 通过
- (void)onResp:(QQBaseResp *)resp {
    if (resp.type != ESENDMESSAGETOQQRESPTYPE) {
        return;
    }
    
    // 分享返回结果
    SendMessageToQQResp* sendReq = (SendMessageToQQResp*)resp;
    
    // 失败
    NSInteger result = 1;
    NSString* message = [NSString stringWithFormat:@"%@ 错误码为 %@", sendReq.errorDescription, sendReq.result];
    
    if (!sendReq.errorDescription && (sendReq.result.integerValue == 0)) {
        result = 0;
        message = @"QQ 分享成功";
    } else if (sendReq.result.integerValue == -4) {
        result = -4;
        message = @"QQ 分享取消";
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareQQ:result:message:)]) {
        [self.delegate shareQQ:self result:result message:message];
    }
}

@end
