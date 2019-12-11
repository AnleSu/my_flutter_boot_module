ucarpaysdkservice
==================

支持多种支付功能: Alipay | ApplePay | PayPal | Union | Wechat  

![UCARPaySDKService](./Resource/UCARPaySDKService.png)

UCARPaySDKService 是所有调用的入口, 通过 UCARPaySDKType 区分。  
```
/**
 SDK 支付防方式
 
 UCARPaySDKTypeUnkown: 未知
 UCARPaySDKTypePaypal:  PayPal
 UCARPaySDKTypeUnion:  云闪付
 UCARPaySDKTypeApplePay: 苹果支付
 UCARPaySDKTypeAliPay: 支付宝
 UCARPaySDKTypeWX: 微信
 */
typedef NS_ENUM(NSInteger, UCARPaySDKType) {
    UCARPaySDKTypeUnkown,
    UCARPaySDKTypePaypal,
    UCARPaySDKTypeUnion,
    UCARPaySDKTypeApplePay,
    UCARPaySDKTypeAliPay,
    UCARPaySDKTypeWX
};  
```


目录预览：  
![UCARPaySDK](./Resource/UCARPaySDK.png)


## 使用
1、导入头文件  
```
#import "UCARPaySDKService.h"
#import "UCARPaySDKRequestModel.h"
```
2、定义属性  
```
// paySDKService
@property (nonatomic, strong) UCARPaySDKService *paySDKService;


#pragma mark -
#pragma mark - lazy
// paySDKService
- (UCARPaySDKService *)paySDKService {
    if (!_paySDKService) {
        _paySDKService = [UCARPaySDKService paySDKServiceWithDelegate:self];
        // 支付宝支付必传
        _paySDKService.aliPayScheme = ALIPAY_URL_SCHEME;
        // 苹果支付必传
        _paySDKService.applePayMerchantId = @"merchant.com.szzc.agentcar";
        // 云闪付必传
        _paySDKService.unionScheme = UNION_PAY_SCHEME;
        _paySDKService.unionMode = @"00";
    }
    return _paySDKService;
}
```

3、微信支付  
`当订单接口仅返回预订单号的请求` 需要自行拼接参数，以及签名。  
```
#pragma mark -
#pragma mark - wechat 支付
- (void)onWeichatPayResult:(NSString *)prepayId withVC:(UIViewController *)vc {
    if (![self checkWechat]) {
        return;
    }
    NSDictionary *dictPayreq = [self sendReqWithPrepayId:prepayId partnerId:kCaiFuTongId appid:kWXAppID];
    UCARPaySDKRequestModel *requestModel = [UCARPaySDKRequestModel paySDKRequestModelWithType:UCARPaySDKTypeWX];
    requestModel.params = dictPayreq;
    if ([self.paySDKService paySDKWithRequestModel:requestModel]) {
        return;
    }
    
    //发起失败
    [self payFailedWithMessage:[UCARBundleManager localizedString:@"UCAR_PAY_BASE_WECHAT_RECHARGE_FAIL"] payType:UCARPayTypeEnumWechat];
}

// 调取微信支付所需参数
- (NSDictionary*)sendReqWithPrepayId:(NSString *)prepayId partnerId:(NSString*)partnerId appid:(NSString*)appid {
    
    int NUMBER_OF_CHARS = 26;
    char data[NUMBER_OF_CHARS];
    for (int x=0; x<NUMBER_OF_CHARS; x++) {
        data[x] = 'A' + arc4random_uniform(26);
    }
    NSString *noncestr = [[NSString alloc] initWithBytes:data length:NUMBER_OF_CHARS encoding:NSUTF8StringEncoding];
    
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
    
    NSString *package = [NSString stringWithFormat:@"Sign=WXPay"];
    // 生成参数字典 (获取 sign)
    NSMutableDictionary *dictPayreq = [[NSMutableDictionary alloc] init];
    [dictPayreq setObject:appid forKey:@"appid"];
    [dictPayreq setObject:package forKey:@"package"];
    [dictPayreq setObject:partnerId forKey:@"partnerid"];
    [dictPayreq setObject:prepayId forKey:@"prepayid"];
    [dictPayreq setObject:noncestr forKey:@"noncestr"];
    
    //消除警告
    NSNumber *timeNum = [NSNumber numberWithInteger:timestamp];
    [dictPayreq setObject:timeNum.stringValue forKey:@"timestamp"];
    //签名
    NSString *sign = [self p_sha1String:dictPayreq];
    
    [dictPayreq setValue:timeNum forKey:@"timestamp"];
    [dictPayreq setValue:sign forKey:@"sign"];
    
    return dictPayreq;
}

/**
 修改原因：通知方式类似群发，无法保证响应的对象即为请求微信支付的对象。
 修改后使用方法调用方式，保证响应者即为发起者
 */
#pragma mark -
#pragma mark - WX 回调
- (BOOL)handleWechatPayURL:(NSURL *)url {
    return [self.paySDKService handleOpenURL:url paySDKType:UCARPaySDKTypeWX];
}
```

`关于签名方法`：
```
#import <CommonCrypto/CommonCrypto.h>
#define kWXPaySignKey        @"daijia2014weixinkaifa2014apimima"


#pragma mark -
#pragma mark - 微信签名
- (NSString *)p_sha1String:(NSDictionary *)dict{
    NSMutableString *signString=[NSMutableString string];
    NSArray *keys = [dict allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    for (NSString *categoryId in sortedArray) {
        if ( [signString length] > 0) {
            [signString appendString:@"&"];
        }
        [signString appendFormat:@"%@=%@", categoryId, [[dict objectForKey:categoryId]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    [signString appendFormat:@"&%@=%@",@"key",kWXPaySignKey];
    
    const char *cStr = [signString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    NSMutableString *stringMd5 = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [stringMd5 appendFormat:@"%02X", digest[i]];
    }
    
    return [stringMd5 copy];
}
```


`订单接口将所有的参数都下发的情况`，直接拉取微信SDK，无需签名。  

```
#pragma mark -
#pragma mark - 租车微信支付
- (void)rcarPayByWechatWithPayInfo:(NSDictionary *)info {
    if (![self checkWechat]) {
        return;
    }
    
    NSData *data = [(NSString *)info[@"reply_tp_reply_info"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *infoDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    UCARPaySDKRequestModel *requestModel = [UCARPaySDKRequestModel paySDKRequestModelWithType:UCARPaySDKTypeWX];
    requestModel.params = infoDict;
    if (infoDict && [self.paySDKService paySDKWithRequestModel:requestModel]) {
        return;
    }
    //发起失败
    [self payFailedWithMessage:[UCARBundleManager localizedString:@"UCAR_PAY_BASE_WECHAT_RECHARGE_FAIL"] payType:UCARPayTypeEnumWechat];
    
}
```

4、支付宝支付  
```
//==========================================
#pragma mark -
#pragma mark - AliPay SDK
- (void)onAlipayPayResult:(NSString *)resultUrl {
    //todo: here we use Alipay interface for pay
    UCARPaySDKRequestModel *requestModel = [UCARPaySDKRequestModel paySDKRequestModelWithType:UCARPaySDKTypeAliPay];
    requestModel.params = resultUrl;
    [self.paySDKService paySDKWithRequestModel:requestModel];
}

- (void)alipayResultWithURL:(NSURL *)url {
    //如果极简开发包不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给开发包
    [self.paySDKService handleOpenURL:url paySDKType:UCARPaySDKTypeAliPay];
}

#pragma mark -
#pragma mark - UCARAlipaySDKDelegate
- (void)aliPaySDKService:(UCARPaySDKService *)paySDKService status:(UCARSDKAlipaySDKStatus)status resultDic:(NSDictionary *)resultDic {
    [UCARClientMonitor event:@"alipayResult" extra:@{MONITOR_CODE_REMARK:resultDic}];
    if (status == UCARSDKAlipaySDKStatusSuccess) {
        [self runResultBlockForTopVCWithPayResult:UCARPayResultSuccess payType:UCARPayTypeEnumAlipayWallet message:NSLocalizedString(@"UCAR_PAY_BASE_ALIPAY_RECHARGE_OK", @"")];
    } else {
        [self payFailedWithMessage:[UCARBundleManager localizedString:@"UCAR_PAY_BASE_ALIPAY_RECHARGE_FIAL"] payType:UCARPayTypeEnumAlipayWallet];
    }
}
```

5、苹果支付
```
#pragma mark -
#pragma mark - Apple Pay
- (void)onApplePayResult:(NSString *)tnCode withVC:(UIViewController *)vc {
    UCARPaySDKRequestModel *requestModel = [UCARPaySDKRequestModel paySDKRequestModelWithType:UCARPaySDKTypeApplePay];
    requestModel.params = tnCode;
    requestModel.viewController = vc;
    [self.paySDKService paySDKWithRequestModel:requestModel];
}

#pragma mark -
#pragma mark - UCARPayUnifyRequestDelegate
- (void)applePaySDKService:(UCARPaySDKService *)paySDKService resultStatus:(UCARSDKPaymentResultStatus)resultStatus message:(NSString *)message {
    if (resultStatus == UCARSDKPaymentResultStatusSuccess) {
        [self runResultBlockForTopVCWithPayResult:UCARPayResultSuccess payType:UCARPayTypeEnumApplePay message:message];
        return;
    } else if (resultStatus == UCARSDKPaymentResultStatusCancel || resultStatus == UCARSDKPaymentResultStatusFailure) {
        //发起失败
        [self payFailedWithMessage:[UCARBundleManager localizedString:@"UCAR_PAY_FAILED_ALERTTITLE"] payType:UCARPayTypeEnumApplePay];
    } else if (resultStatus == UCARSDKPaymentResultStatusUnknownCancel){
        [UCARProgressManager showErrorMessage:NSLocalizedString(@"UCAR_PAY_PROCESS_ALERTTITLE", @"")];
    }
}
```

6、云闪付
```
//==============================
#pragma mark -
#pragma mark - UnionPay PaymentControl
- (void)onUnionPayRequestResult:(NSString *)tnCode withVC:(UIViewController *)vc {
    if (![Utility isEmptyObj:tnCode]) {
        UCARPaySDKRequestModel *requestModel = [UCARPaySDKRequestModel paySDKRequestModelWithType:UCARPaySDKTypeUnion];
        requestModel.params = tnCode;
        requestModel.viewController = vc;
        BOOL isSuccess = [self.paySDKService paySDKWithRequestModel:requestModel];
        if (!isSuccess) {
            NSLog(@"银联支付控件调起失败");
        }
    }
}

// 银联手机控件支付请求结果
- (void)unionPayControlResultWithURL:(NSURL *)url {
    [self.paySDKService handleOpenURL:url paySDKType:UCARPaySDKTypeUnion];
}

#pragma mark -
#pragma mark - UCARPaymentControlDelegate
- (void)unionPaySDKService:(UCARPaySDKService *)paySDKService resultStatus:(UCARUNIONSDKResultStatus)resultStatus {
    if (resultStatus == UCARUNIONSDKResultStatusSuccess) {
        [self runResultBlockForTopVCWithPayResult:UCARPayResultSuccess payType:UCARPayTypeEnumUnionPay message:NSLocalizedString(@"UCAR_PAY_BASE_UNIONPAY_RECHARGE_OK", @"")];
    } else {
        [self payFailedWithMessage:[UCARBundleManager localizedString:@"UCAR_PAY_BASE_UNIONPAY_RECHARGE_FAIL"] payType:UCARPayTypeEnumUnionPay];
    }
}
```

7、PayPal 支付
```
#pragma mark -
#pragma mark - PayPalPayment & Delegate
- (void)onPayPalResult:(NSDictionary *)responseDict withVC:(UIViewController *)vc {
    UCARPaySDKRequestModel *requestModel = [UCARPaySDKRequestModel paySDKRequestModelWithType:UCARPaySDKTypePaypal];
    requestModel.params = responseDict;
    requestModel.viewController = vc;
    [self.paySDKService paySDKWithRequestModel:requestModel];
}
```

8、其它
```
#pragma mark -
#pragma mark - 微信
/**
 注册微信
 */
+ (void)registerActiveWX:(NSString *)appid;

/**
 是否安装了对应支付方式的 APP
 
 @note 目前支持 微信 | 支付宝 | 云闪付
 */
+ (BOOL)installedAppWithPaySDKType:(UCARPaySDKType)paySDKType;

/**
 是否支持 Api
 */
+ (BOOL)isWXAppSupportApi;
```
