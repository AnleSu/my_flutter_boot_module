//
//  UCARPaySDKService.m
//  UCARPlatform
//
//  Created  by hong.zhu on 2019/2/15.
//  Copyright © 2019年 UCar. All rights reserved.
//

#import "UCARPaySDKService.h"
#import "UCARPaySDKRequestModel.h"
#import "NSObject+UCARMethod.h"

#define CreateNSError(errorCode,errorMessage) [NSError errorWithDomain:NSCocoaErrorDomain code:errorCode userInfo:@{@"message":errorMessage}]

@interface UCARPaySDKService ()

// 代理
@property (nonatomic, weak) id<UCARPaySDKDelegate> delegate;
// Paypal
@property (nonatomic, strong) id payPalService;
// 云闪付
@property (nonatomic, strong) id unionInService;
// Apple Pay
@property (nonatomic, strong) id applePayService;
// 支付宝
@property (nonatomic, strong) id aliPayService;
// 微信
@property (nonatomic, strong) id wxService;

@end

@implementation UCARPaySDKService

// 通过 delegate 创建实例
+ (instancetype)paySDKServiceWithDelegate:(id<UCARPaySDKDelegate>)delegate {
    UCARPaySDKService *paySDKService = [self new];
    paySDKService.delegate = delegate;
    return paySDKService;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
// 注册微信
+ (void)registerActiveWX:(NSString *)appid {
    if (!appid) {
        return;
    }
    Class cls = ucarmethod_scheduler_getClass("UCARWXApi");
    SEL sel = @selector(registerApp:);
    if (cls && [cls respondsToSelector:sel]) {
        [cls ucarmethod_executeMethod:sel params:@[appid]];
    } else {
        NSLog(@"请引入 UCARWXApi");
    }
}

// 发起支付
- (BOOL)paySDKWithRequestModel:(UCARPaySDKRequestModel *)requestModel {
    switch (requestModel.paySDKType) {
        case UCARPaySDKTypePaypal:
        {
            // Paypal
            return [self payPaypalSDKWithRequestModel:requestModel];
        }
            break;
        case UCARPaySDKTypeUnion:
        {
            // 云闪付
            return [self payUnionPaySDKWithRequestModel:requestModel];
        }
            break;
        case UCARPaySDKTypeApplePay:
        {
            // 苹果支付
            return [self payApplePaySDKWithRequestModel:requestModel];
        }
            break;
        case UCARPaySDKTypeAliPay:
        {
            // 支付宝
            return [self payAliPaySDKWithRequestModel:requestModel];
        }
            break;
        case UCARPaySDKTypeWX:
        {
            // 微信
            return [self payWXSDKWithRequestModel:requestModel];
        }
            break;
            
        default:
            break;
    }
    return YES;
}

// Paypal
- (BOOL)payPaypalSDKWithRequestModel:(UCARPaySDKRequestModel *)requestModel {
    SEL sel = @selector(onPayPalResult:withVC:);
    if (self.payPalService && [self.payPalService respondsToSelector:sel] && requestModel.params && requestModel.viewController) {
        [self.payPalService ucarmethod_executeMethod:sel params:@[requestModel.params, requestModel.viewController]];
    } else {
        NSLog(@"请引入 UCARPayPalMobile");
        return NO;
    }
    return YES;
}
// 云闪付
- (BOOL)payUnionPaySDKWithRequestModel:(UCARPaySDKRequestModel *)requestModel {
    SEL sel = @selector(startPay:viewController:);
    if (self.unionInService && [self.unionInService respondsToSelector:sel]) {
        NSNumber *boolNumber = [self.unionInService ucarmethod_executeMethod:sel params:@[requestModel.params, requestModel.viewController]];
        return boolNumber.boolValue;
    } else {
        NSLog(@"请引入 UCARPayUnifyRequest");
        return NO;
    }
}

// Apple 支付
- (BOOL)payApplePaySDKWithRequestModel:(UCARPaySDKRequestModel *)requestModel {
    SEL sel = @selector(applePayRequestWithTnCode:viewController:);
    if (self.applePayService && [self.applePayService respondsToSelector:sel] && requestModel.params && requestModel.viewController) {
        [self.applePayService ucarmethod_executeMethod:sel params:@[requestModel.params, requestModel.viewController]];
    } else {
        NSLog(@"请引入 UCARPayUnifyRequest");
        return NO;
    }
    return YES;
}

// 发起支付宝支付
- (BOOL)payAliPaySDKWithRequestModel:(UCARPaySDKRequestModel *)requestModel {
    SEL sel = @selector(payOrder:);
    if (self.aliPayService && [self.aliPayService respondsToSelector:sel] && requestModel.params) {
        [self.aliPayService ucarmethod_executeMethod:sel params:@[requestModel.params]];
    } else {
        NSLog(@"请引入 UCARAlipaySDK");
        return NO;
    }
    return YES;
}

// 微信支付
- (BOOL)payWXSDKWithRequestModel:(UCARPaySDKRequestModel *)requestModel {
    SEL sel = @selector(sendReqWithInfoDict:);
    if (self.wxService && [self.wxService respondsToSelector:sel] && requestModel.params) {
        NSNumber * boolNumber = [self.wxService ucarmethod_executeMethod:sel params:@[requestModel.params]];
        return boolNumber.boolValue;
    } else {
        NSLog(@"请引入 UCARWXApi");
        return NO;
    }
}

#pragma mark -
#pragma mark - handleOpenURL
- (BOOL)handleOpenURL:(NSURL *)url paySDKType:(UCARPaySDKType)paySDKType {
    SEL sel = @selector(handleOpenURL:);
    switch (paySDKType) {
        case UCARPaySDKTypeWX:
        {
            if (self.wxService && [self.wxService respondsToSelector:sel] && [url.host isEqualToString:@"pay"]) {
                NSNumber *boolNumber = [self.wxService ucarmethod_executeMethod:sel params:@[url]];
                return boolNumber.boolValue;
            } else {
                NSLog(@"请引入 UCARWXApi");
                return NO;
            }
        }
            break;
        case UCARPaySDKTypeAliPay:
        {
            if (self.aliPayService && [self.aliPayService respondsToSelector:sel]) {
                NSNumber *boolNumber = [self.aliPayService ucarmethod_executeMethod:sel params:@[url]];
                return boolNumber.boolValue;
            } else {
                NSLog(@"请引入 UCARAlipaySDK");
                return NO;
            }
        }
            break;
        case UCARPaySDKTypeUnion:
        {
            if (self.unionInService && [self.unionInService respondsToSelector:sel]) {
                NSNumber *boolNumber = [self.unionInService ucarmethod_executeMethod:sel params:@[url]];
                return boolNumber.boolValue;
            } else {
                NSLog(@"请引入 UCARAlipaySDK");
                return NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    return NO;
}

#pragma mark -
#pragma mark - UCARPayPalMobileDelegate
// 支付完成, 向服务器请求支付结果
- (void)payPalMobile:(id)payPalMobile completedForParams:(nonnull NSDictionary *)params controller:(nonnull UIViewController *)paymentViewController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(paypalSDKService:completedForParams:controller:)]) {
        [self.delegate paypalSDKService:self completedForParams:params controller:paymentViewController];
    }
}

// 交易取消
- (void)didCancelWithPayPalMobile:(id)payPalMobile {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCancelWithPaypalSDKService:)]) {
        [self.delegate didCancelWithPaypalSDKService:self];
    }
}

#pragma mark -
#pragma mark - UCARPaymentControlDelegate
- (void)paymentControl:(id)paymentControl resultStatus:(NSInteger)resultStatus {
    if (self.delegate && [self.delegate respondsToSelector:@selector(unionPaySDKService:resultStatus:)]) {
        [self.delegate unionPaySDKService:self resultStatus:resultStatus];
    }
}

#pragma mark -
#pragma mark - UCARPayUnifyRequestDelegate
- (void)payUnifyRequest:(id)payUnifyRequest resultStatus:(NSInteger)resultStatus message:(NSString *)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(applePaySDKService:resultStatus:message:)]) {
        [self.delegate applePaySDKService:self resultStatus:resultStatus message:message];
    }
}

#pragma mark -
#pragma mark - UCARAlipaySDKDelegate
- (void)alipaySDK:(id)alipaySDK status:(NSInteger)status resultDic:(NSDictionary *)resultDic {
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliPaySDKService:status:resultDic:)]) {
        [self.delegate aliPaySDKService:self status:status resultDic:resultDic];
    }
}

// 是否安装了对应支付方式的 APP
+ (BOOL)installedAppWithPaySDKType:(UCARPaySDKType)paySDKType {
    BOOL installedApp = NO;
    switch (paySDKType) {
        case UCARPaySDKTypeUnion:
        {
            installedApp = [self p_isPaymentAppInstalled];
        }
            break;
        case UCARPaySDKTypeAliPay:
        {
            installedApp = [self p_installAlipay];
        }
            break;
        case UCARPaySDKTypeWX:
        {
            installedApp = [self p_isWXAppInstalled];
        }
            break;
            
        default:
            break;
    }
    return installedApp;
}

// 微信是否支持 Api
+ (BOOL)isWXAppSupportApi {
    return [self p_isWXAppInfo:NO];
}

#pragma mark -
#pragma mark - 私有方法
// 是否已经安装了银联支付 APP
+ (BOOL)p_isPaymentAppInstalled {
    SEL sel = @selector(isPaymentAppInstalled);
    Class cls = ucarmethod_scheduler_getClass("UCARPaymentControl");
    if (cls && [cls respondsToSelector:sel]) {
        NSNumber * boolNumber = [cls ucarmethod_executeMethod:sel];
        return boolNumber.boolValue;
    } else {
        NSLog(@"请引入 UCARPaymentControl");
        return NO;
    }
}

// 是否已经安装了支付宝
+ (BOOL)p_installAlipay {
    if ([self p_canOpenURL:[NSURL URLWithString:@"alipays://"]]) {
        return YES;
    }
    return NO;
}

// 微信是否已经安装
+ (BOOL)p_isWXAppInstalled {
    return [self p_isWXAppInfo:YES];
}

// 微信
+ (BOOL)p_isWXAppInfo:(BOOL)installed {
    SEL sel = @selector(isWXAppSupportApi);
    if (installed) {
        sel = @selector(isWXAppInstalled);
    }
    Class cls = ucarmethod_scheduler_getClass("UCARWXApi");
    if (cls && [cls respondsToSelector:sel]) {
        NSNumber * boolNumber = [cls ucarmethod_executeMethod:sel];
        return boolNumber.boolValue;
    } else {
        NSLog(@"请引入 UCARWXApi");
        return NO;
    }
}

/** 是否能打开 url App */
+ (BOOL)p_canOpenURL:(NSURL*)url {
    if (!url) {
        return NO;
    }
    return [[UIApplication sharedApplication] canOpenURL:url];
}


#pragma mark -
#pragma mark - UCARWXApiDelegate
// 微信支付回调
- (void)wxApi:(id)wxApi code:(NSInteger)code message:(NSString*)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxPaySDKService:code:message:)]) {
        [self.delegate wxPaySDKService:self code:code message:message];
    }
}

#pragma mark -
#pragma mark - lazy
// Paypal
- (id)payPalService {
    if (!_payPalService) {
        Class cls = ucarmethod_scheduler_getClass("UCARPayPalMobile");
        SEL sel = @selector(payPalMobileWithDelegate:);
        if (cls && [cls respondsToSelector:sel]) {
            _payPalService = [cls ucarmethod_executeMethod:sel params:@[self]];
        } else {
            NSLog(@"请引入 UCARPayPalMobile");
        }
    }
    return _payPalService;
}

// 云闪付
- (id)unionInService {
    if (!_unionInService) {
        Class cls = ucarmethod_scheduler_getClass("UCARPaymentControl");
        SEL sel = @selector(paymentControlWithFromScheme:mode:delegate:);
        if (cls && [cls respondsToSelector:sel]) {
            if (!self.unionScheme) {
                NSLog(@"请给 _unionScheme 赋值");
                return nil;
            }
            
            if (!self.unionMode) {
                NSLog(@"请给 _unionMode 赋值");
                return nil;
            }
            
            _unionInService = [cls ucarmethod_executeMethod:sel params:@[self.unionScheme, self.unionMode, self]];
        } else {
            NSLog(@"请引入 UCARPaymentControl");
        }
    }
    return _unionInService;
}

// Apple Pay
- (id)applePayService {
    if (!_applePayService) {
        Class cls = ucarmethod_scheduler_getClass("UCARPayUnifyRequest");
        SEL sel = @selector(unifyRequestWithApplePayMerchantId:delegate:);
        if (cls && [cls respondsToSelector:sel]) {
            if (self.applePayMerchantId) {
                _applePayService = [cls ucarmethod_executeMethod:sel params:@[self.applePayMerchantId, self]];
            } else {
                NSLog(@"请给 _applePayMerchantId 赋值");
            }
        } else {
            NSLog(@"请引入 UCARPayUnifyRequest");
        }
    }
    return _applePayService;
}

// 支付宝
- (id)aliPayService {
    if (!_aliPayService) {
        Class cls = ucarmethod_scheduler_getClass("UCARAlipaySDK");
        SEL sel = @selector(alipaySDKWithScheme:delegate:);
        if (cls && [cls respondsToSelector:sel]) {
            if (self.aliPayScheme) {
                _aliPayService = [cls ucarmethod_executeMethod:sel params:@[self.aliPayScheme, self]];
            } else {
                NSLog(@"请给 _aliPayScheme 赋值");
            }
            
        } else {
            NSLog(@"请引入 UCARAlipaySDK");
        }
    }
    return _aliPayService;
}

// 微信
- (id)wxService {
    if (!_wxService) {
        Class cls = ucarmethod_scheduler_getClass("UCARWXApi");
        SEL sel = @selector(wxApiWithDelegate:);
        if (cls && [cls respondsToSelector:sel]) {
            _wxService = [cls ucarmethod_executeMethod:sel params:@[self]];
        } else {
            NSLog(@"请引入 UCARWXApi");
        }
    }
    return _wxService;
}

#pragma clang diagnostic pop

@end
