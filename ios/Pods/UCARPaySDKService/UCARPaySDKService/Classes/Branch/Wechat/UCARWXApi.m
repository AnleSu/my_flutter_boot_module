//
//  UCARWXApi.m
//  UCARPlatform
//
//  Created  by hong.zhu on 2019/2/11.
//  Copyright © 2019年 UCar. All rights reserved.
//

#import "UCARWXApi.h"
#import <WXApi.h>
#import <WXApiObject.h>

@interface UCARWXApi () <WXApiDelegate>

// 代理
@property (nonatomic, weak) id<UCARWXApiDelegate> delegate;

@end

@implementation UCARWXApi

// 快速获取对象
+ (instancetype)wxApiWithDelegate:(id<UCARWXApiDelegate>)delegate {
    UCARWXApi *wxApi = [self new];
    wxApi.delegate = delegate;
    return wxApi;
}

/*! @brief WXApi的成员函数，向微信终端程序注册第三方应用。
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL)registerApp:(NSString *)appid {
    return [WXApi registerApp:appid];
}

// 是否已经安装
+ (BOOL)isWXAppInstalled {
    return [WXApi isWXAppInstalled];
}
// 是否支持 Api
+ (BOOL)isWXAppSupportApi {
    return [WXApi isWXAppSupportApi];
}

// 调取微信支付(租车)
- (BOOL)sendReqWithInfoDict:(NSDictionary *)infoDict {
    NSString *partnerId = [infoDict objectForKey:@"partnerid"];
    NSString *prepayId = [infoDict objectForKey:@"prepayid"];
    NSString *noncestr = [infoDict objectForKey:@"noncestr"];
    NSString *package = [infoDict objectForKey:@"package"];
    int timestamp = [[infoDict objectForKey:@"timestamp"] intValue];
    NSString *sign = [infoDict objectForKey:@"sign"];
    //调起微信支付
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = partnerId;
    request.prepayId= prepayId;
    request.package = package;
    request.nonceStr = noncestr;
    request.timeStamp = timestamp;
    request.sign= sign;
    
    return [WXApi sendReq:request];
}

#pragma mark -
#pragma mark - handleOpenURL
- (BOOL)handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark -
#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    NSLog(@"onResp --- %d", resp.errCode);
    if ([resp isKindOfClass:[PayResp class]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(wxApi:code:message:)]) {
            [self.delegate wxApi:self code:resp.errCode message:resp.errStr];
        }
    }
}

@end
