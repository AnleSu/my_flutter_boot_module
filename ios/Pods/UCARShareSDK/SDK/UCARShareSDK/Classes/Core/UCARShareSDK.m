//
//  UCARShareSDK.m
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import "UCARShareSDK.h"
#import "UCARBaseShare.h"
#import "NSObject+UCARMethod.h"
#import <UCARLogger/UCARLogger.h>

// 是否自行了 handleOpenURL: 方法
static BOOL kExecuteHandleOpenURL = NO;

@interface UCARShareSDK ()

// 代理
@property (nonatomic, weak) id<UCARShareSDKDelegate> delegate;

// 发短息
@property (nonatomic, strong) UCARBaseShare *shareSMS;
// 发微博
@property (nonatomic, strong) UCARBaseShare *shareSina;
// 微信
@property (nonatomic, strong) UCARBaseShare *shareWX;
// 发微博
@property (nonatomic, strong) UCARBaseShare *shareQQ;

@end

@implementation UCARShareSDK

// 通过 delegate 获取实例
+ (instancetype)shareSDKWithDelegate:(id<UCARShareSDKDelegate>)delegate {
    UCARShareSDK *shareSDK = [self new];
    shareSDK.delegate = delegate;
    return shareSDK;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // 监听 UIApplicationDidBecomeActiveNotification 通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

// 发起分享
- (NSString*)shareSDKWithItem:(UCARShareItem*)shareItem {
    __weak UCARBaseShare *share = nil;
    switch (shareItem.shareType) {
        case UCARShareTypeSMS:
        {
            share = self.shareSMS;
        }
            break;
        case UCARShareTypeSina:
        {
            share = self.shareSina;
        }
            break;
        case UCARShareTypeMiniProgram:
        case UCARShareTypeOpenMiniProgram:
        case UCARShareTypeWeChatSession:
        case UCARShareTypeWechatTimeline:
        {
            share = self.shareWX;
        }
            break;
        case UCARShareTypeQQZone:
        case UCARShareTypeQQSession:
        {
            share = self.shareQQ;
        }
            break;
            
        default:
            break;
    }
    
    NSString *message = @"未知结果";
    if (share && [share respondsToSelector:@selector(shareWithItem:)]) {
        // 保留当前分享方式
        self.shareType = shareItem.shareType;
        
        message = [share shareWithItem:shareItem];
    }
    return message;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

// 初始化ShareSDK应用
+ (void)registerActivePlatforms:(NSArray *)activePlatforms onConfiguration:(UCARKConfigurationHandler)configurationHandler {
    
    if (!configurationHandler) {
        return;
    }
    
    for (NSNumber *num in activePlatforms) {
        UCARShareType shareType = num.integerValue;
        char * clazzChar = "";
        switch (shareType) {
                case UCARShareTypeWeChatSession:
                clazzChar = "UCARShareWX";
                break;
                case UCARShareTypeQQSession:
                clazzChar = "UCARShareQQ";
                break;
                case UCARShareTypeSina:
                clazzChar = "UCARShareSina";
                break;
            default:
                break;
        }
        Class clazz = ucarmethod_scheduler_getClass(clazzChar);
        if (clazz) {
            UCARSDKSetupTools *setupTools = [UCARSDKSetupTools setupToolsWithClazz:clazz];
            configurationHandler(shareType, setupTools);
        }
    }
}

// handleOpenURL
+ (BOOL)handleOpenURL:(NSURL *)url {
    // 记录 handleOpenURL: 方法被执行
    kExecuteHandleOpenURL = YES;
    
    // 以通知的形式将数据传递出去
    [[NSNotificationCenter defaultCenter] postNotificationName:UCARDMethodHOpenURLNotification object:url];
    
    return YES;
}

#pragma mark -
#pragma mark - 安装
// 是否安装客户端（支持平台：微博、微信、QQ）
+ (BOOL)isClientInstalledWithShareType:(UCARShareType)shareType {
    BOOL installApp = NO;
    // 获取对应类型的 Class
    Class clazz = nil;
    
    switch (shareType) {
        case UCARShareTypeWeChatSession:
        case UCARShareTypeWechatTimeline:
        case UCARShareTypeMiniProgram:
        case UCARShareTypeOpenMiniProgram:
        {
            // 微信
            clazz = ucarmethod_scheduler_getClass("UCARShareWX");
        }
            break;
        case UCARShareTypeQQZone:
        case UCARShareTypeQQSession:
        {
            // QQ
            clazz = ucarmethod_scheduler_getClass("UCARShareQQ");
        }
            break;
        case UCARShareTypeSina:
        {
            // 微博
            clazz = ucarmethod_scheduler_getClass("UCARShareSina");
        }
            break;
        case UCARShareTypeSMS:
        {
            clazz = ucarmethod_scheduler_getClass("UCARShareSMS");
        }
            break;
            
        default:
            break;
    }
    
    SEL sel = @selector(isAppInstalled);
    if (clazz && [clazz respondsToSelector:sel]) {
        NSNumber *boolNumber = [clazz ucarmethod_executeMethod:sel];
        installApp = boolNumber.boolValue;
    }
    
    return installApp;
}

#pragma mark -
#pragma mark - 通知监听方法
- (void)applicationDidBecomeActiveNotification:(NSNotification*)noti {
    if ((self.shareType != UCARShareTypeNone) && !kExecuteHandleOpenURL) {
        // self.shareType 的值不为 UCARShareTypeNone, 说明当前是在进入过分享的情况下跳转第三方 SDK
        // !kExecuteHandleOpenURL 说明 handleOpenURL: 方法没有被执行
        
        if (!self.delegate || ![self.delegate respondsToSelector:@selector(shareSDK:result:message:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 强制变成取消
                [self.delegate shareSDK:self result:UCARShareSDKResultCancel message:@"取消分享"];
            });
        }
    }
    
    kExecuteHandleOpenURL = NO;
}

#pragma mark -
#pragma mark - UCARShareSMSDelegate
// SMS 结果返回
- (void)shareSMS:(id)shareSMS didSMSWithResult:(UCARMessageComposeResult)result message:(NSString*)message {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(shareSDK:result:message:)]) {
        return;
    }
    
    UCARShareSDKResult shareSDKResult = UCARShareSDKResultSuccess;
    switch (result) {
        case UCARMessageComposeResultCancelled:
        {
            shareSDKResult = UCARShareSDKResultCancel;
        }
            break;
        case UCARMessageComposeResultFailed:
        {
            shareSDKResult = UCARShareSDKResultFail;
        }
            break;
            
        default:
            break;
    }
    
    [self.delegate shareSDK:self result:shareSDKResult message:message];
}

#pragma mark -
#pragma mark -  UCARShareSinaDelegate
- (void)shareSina:(id)shareSina result:(UCARWeiboSDKResponseStatusCode)result message:(NSString*)message {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(shareSDK:result:message:)]) {
        return;
    }
    
    UCARShareSDKResult shareSDKResult = UCARShareSDKResultFail;
    switch (result) {
        case UCARWeiboSDKResponseStatusCodeUserCancel:
        {
            shareSDKResult = UCARShareSDKResultCancel;
        }
            break;
        case UCARWeiboSDKResponseStatusCodeSuccess:
        {
            shareSDKResult = UCARShareSDKResultSuccess;
        }
            break;
            
        default:
            break;
    }
    
    [self.delegate shareSDK:self result:shareSDKResult message:message];
    
}

#pragma mark -
#pragma mark - UCARShareWXDelegate
// 返回结果
- (void)shareWX:(id)shareWX result:(UCARWXErrCode)result message:(NSString*)message {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(shareSDK:result:message:)]) {
        return;
    }
    
    UCARShareSDKResult shareSDKResult = UCARShareSDKResultFail;
    switch (result) {
        case UCARWXErrCodeUserCancel:
        {
            shareSDKResult = UCARShareSDKResultCancel;
        }
            break;
        case UCARWXSuccess:
        {
            shareSDKResult = UCARShareSDKResultSuccess;
        }
            break;
            
        default:
            break;
    }
    
    [self.delegate shareSDK:self result:shareSDKResult message:message];
}

#pragma mark -
#pragma mark - UCARShareQQDelegate
// 返回结果
- (void)shareQQ:(id)shareQQ result:(UCARQQErrCode)result message:(NSString*)message {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(shareSDK:result:message:)]) {
        return;
    }
    
    UCARShareSDKResult shareSDKResult = UCARShareSDKResultSuccess;
    if (result == UCARQQErrFail) {
        shareSDKResult = UCARShareSDKResultFail;
    } else if (result == UCARQQErrCancel) {
        shareSDKResult = UCARShareSDKResultCancel;
    }
    [self.delegate shareSDK:self result:shareSDKResult message:message];
}

#pragma mark -
#pragma mark - lazy
// 发短息
- (UCARBaseShare*)shareSMS {
    if (!_shareSMS) {
        Class clazz = ucarmethod_scheduler_getClass("UCARShareSMS");
        if (clazz) {
            _shareSMS = [clazz alloc];
            _shareSMS = [_shareSMS initWithDelegate:self];
        } else {
            UCARLoggerDebug(@"请引入 UCARShareSMS");
        }
    }
    return _shareSMS;
}

// 发微博
- (UCARBaseShare*)shareSina {
    if (!_shareSina) {
        Class clazz = ucarmethod_scheduler_getClass("UCARShareSina");
        if (clazz) {
            _shareSina =[clazz alloc];
            _shareSina = [_shareSina initWithDelegate:self];
        } else {
            UCARLoggerDebug(@"请引入 UCARShareSina");
        }
    }
    return _shareSina;
}

// 微信
- (UCARBaseShare *)shareWX {
    if (!_shareWX) {
        Class clazz = ucarmethod_scheduler_getClass("UCARShareWX");
        if (clazz) {
            _shareWX =[clazz alloc];
            _shareWX = [_shareWX initWithDelegate:self];
        } else {
            UCARLoggerDebug(@"请引入 UCARShareWX");
        }
    }
    return _shareWX;
}

- (UCARBaseShare *)shareQQ {
    if (!_shareQQ) {
        Class clazz = ucarmethod_scheduler_getClass("UCARShareQQ");
        if (clazz) {
            _shareQQ =[clazz alloc];
            _shareQQ = [_shareQQ initWithDelegate:self];
        } else {
            UCARLoggerDebug(@"请引入 UCARShareQQ");
        }
    }
    return _shareQQ;
}

#pragma clang diagnostic pop

- (void)dealloc {
    UCARLoggerDebug(@"UCARShareSDK - dealloc = %@", self);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
