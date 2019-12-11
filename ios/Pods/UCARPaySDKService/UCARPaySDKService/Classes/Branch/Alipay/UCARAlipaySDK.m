//
//  UCARAlipaySDK.m
//  UCARPlatform
//
//  Created  by hong.zhu on 2019/2/11.
//  Copyright © 2019年 UCar. All rights reserved.
//

#import "UCARAlipaySDK.h"
#import <AlipaySDK/AlipaySDK.h>

@interface UCARAlipaySDK ()

// 代理
@property (nonatomic, weak) id<UCARAlipaySDKDelegate> delegate;
/**
 scheme
 */
@property (nonatomic, copy) NSString* fromScheme;

@end

@implementation UCARAlipaySDK

/** 快速获取对象 */
+ (instancetype)alipaySDKWithScheme:(NSString *)fromScheme delegate:(id<UCARAlipaySDKDelegate>)delegate {
    UCARAlipaySDK *alipaySDK = [self new];
    alipaySDK.delegate = delegate;
    alipaySDK.fromScheme = fromScheme.copy;
    return alipaySDK;
}

// 支付接口
- (void)payOrder:(NSString *)orderStr {
    NSString *fromScheme = self.fromScheme?:@"";
    [[AlipaySDK defaultService] payOrder:orderStr fromScheme:fromScheme callback:^(NSDictionary *resultDic) {
        //Alipay v15.1.0以后，该block仅在H5支付时回调
        [self alipayPayResultWithDict:resultDic];
    }];
}

#pragma mark -
#pragma mark - handleOpenURL
- (BOOL)handleOpenURL:(NSURL *)url {
    if ([url.host isEqualToString:@"safepay"]) {
        [self processOrderWithPaymentResult:url];
    }
    
    if ([url.host isEqualToString:@"platformapi"]) {
        //支付宝钱包快登授权返回 authCode
        [self processAuthResult:url];
    }
    
    return YES;
}

// 处理钱包或者独立快捷app支付跳回商户app携带的支付结果Url
- (void)processOrderWithPaymentResult:(NSURL *)resultUrl {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:resultUrl standbyCallback:^(NSDictionary *resultDic) {
        // Alipay v15.1.0以后，该block仅在App支付时回调
        [self alipayPayResultWithDict:resultDic];
    }];
}

// 处理授权信息Url
- (void)processAuthResult:(NSURL *)resultUrl {
    [[AlipaySDK defaultService] processAuthResult:resultUrl standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"platformapi result = %@",resultDic);
    }];
}

// 支付结果回调
- (void)alipayPayResultWithDict:(NSDictionary *)resultDic {
    NSLog(@"recharge reslut = %@",resultDic);
    NSDictionary *dictionary = resultDic?resultDic:@{};
    int resultStatus = [[resultDic valueForKey:@"resultStatus"] intValue];
    
    // 据最新官方文判断 status 即可视为支付成功 : https://docs.open.alipay.com/204/105302
    UCARAlipaySDKStatus status = (resultStatus == 9000)?UCARAlipaySDKStatusSuccess:UCARAlipaySDKStatusFailure;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(alipaySDK:status:resultDic:)]) {
        [self.delegate alipaySDK:self status:status resultDic:dictionary];
    }
}

@end
