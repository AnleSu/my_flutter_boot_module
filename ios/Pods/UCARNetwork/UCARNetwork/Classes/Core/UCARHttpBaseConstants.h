//
//  UCARHttpConstants.h
//  UCar
//
//  Created by KouArlen on 16/3/7.
//  Copyright © 2016年 zuche. All rights reserved.
//

#import <Foundation/Foundation.h>

//===================Error=================
FOUNDATION_EXPORT NSString *const UCARDNSCheckErrorDomain;
typedef NS_ENUM(NSInteger, UCARDNSCheckErrorCode) {
    UCARDNSCheckErrorCodeHijacked = 0,
    UCARDNSCheckErrorCodeDNSParseError = 1
};
//=========================================
FOUNDATION_EXPORT NSString *const UCARHttpErrorDomain;
typedef NS_ENUM(NSInteger, UCARHttpErrorCode) {
    UCARHttpErrorCodeResponseNull = 1,
    UCARHttpErrorCodeDecryptFailed = 2,
    UCARHttpErrorCodeJSONParseFailed = 3,
};
//=========================================
FOUNDATION_EXPORT NSString *const UCARHttpMAPIErrorDomain;
FOUNDATION_EXPORT const NSInteger UCARHttpMAPICodeSuccess;

// 360版MAPI code码参考
// http://gitlab.10101111.com:8888/ucarapi/apibasemodules/wikis/APIResult
typedef NS_ENUM(NSInteger, UCARHttpResponseCode) {
    // SUCCESS 成功。
    UCARHttpResponseCodeSuccess = 1,
    // API_NOT_FIND API 不存在。
    UCARHttpResponseCodeAPINotFound = 2,
    // LIMIT_ERROR 调用频率超过限制。
    UCARHttpResponseCodeLimitError = 3,
    // NO_AUTH 客户端的 API 权限不足。
    UCARHttpResponseCodeNOAuth = 4,
    // NOT_LOGIN 未登录或者登录已超时。
    UCARHttpResponseCodeNotLogin = 5,
    // MAPI_ERROR 服务器内部错误（未知错误）。
    UCARHttpResponseCodeMAPIError = 6,
    // BASE_ERROR 业务错误。此时具体业务错误，请参考 busiCode。
    UCARHttpResponseCodeBaseError = 7,
    // SECURITY_ERROR 客户端身份检查未通过。
    UCARHttpResponseCodeSecurityError = 8,
    // PARAM_ERROR 参数错误。
    UCARHttpResponseCodeParamError = 9,
    // INVOKER_INIT_FAIL 客户端身份初始化失败。
    UCARHttpResponseCodeInvokerInitFail = 10,
    // PROTOCOL_ERROR 请求协议不支持。
    UCARHttpResponseCodeProtocolError = 12,
    // SECRETKEY_EXPIRED 秘钥过期。
    UCARHttpResponseCodeSecretKeyExpired = 13,
    // APIVersionNotSupport MAPI版本不再支持。
    UCARHttpResponseCodeAPIVersionNotSupport = 16,
    // SECURITY_KEY_IS_NULL 密钥为空。
    UCARHttpResponseCodeSecretKeyIsNull = 17,
    // ASYNC_TOKEN_MISSING 异步token缺失。
    UCARHttpResponseCodeAsyncTokenMissing = 18,
    // FILTER_INTERRUPT 过滤器拒绝了该请求。
    UCARHttpResponseCodeFilterInterrupy = 19,
    // INTERCEPTOR_INTERRUPT 拦截器拒绝了该请求。
    UCARHttpResponseCodeInterceptorInterrupt = 20,
    // API_UNABLE 该API已暂停使用。
    UCARHttpResponseCodeAPIUnable = 21,
    // INNER_SERVICE_ERROR API与内部服务通信出现异常。
    UCARHttpResponseCodeInnerServiceError = 22
};

//注意：UCARHttpMAPIErrorCode包含上面的UCARHttpResponseCode值
typedef NS_ENUM(NSInteger, UCARHttpMAPIErrorCode) {
    UCARHttpMAPIErrorCodeMAPINotReady = -100,
};
//=================================================

FOUNDATION_EXPORT const NSInteger UCARHttpTimeOut;

FOUNDATION_EXPORT NSString *const UCARHttpRSAPublicKey;
FOUNDATION_EXPORT NSString *const UCARHttpSessionID;

// EnvConfigKey
FOUNDATION_EXPORT NSString *const UCARHttpKeyMAPIServerDomain;
FOUNDATION_EXPORT NSString *const UCARHttpKeyMAPIServerIP;

FOUNDATION_EXPORT NSString *const UCARHttpKeyDomain;
FOUNDATION_EXPORT NSString *const UCARHttpKeyIP;

// RequestKey
FOUNDATION_EXPORT NSString *const UCARHttpRequestHeader;
FOUNDATION_EXPORT NSString *const UCARHttpKeyEventID;
FOUNDATION_EXPORT NSString *const UCARHttpKeySecretKey;
FOUNDATION_EXPORT NSString *const UCARHttpKeyDeviceID;

FOUNDATION_EXPORT NSString *const UCARHttpResponseKeyCode;
FOUNDATION_EXPORT NSString *const UCARHttpResponseKeyContent;
FOUNDATION_EXPORT NSString *const UCARHttpResponseKeyUID;
FOUNDATION_EXPORT NSString *const UCARHttpResponseKeyMsg;

// 360版MAPI新增handler字段，详见http://gitlab.10101111.com:8888/ucarapi/apibasemodules/wikis/APIResult
FOUNDATION_EXPORT NSString *const UCARHttpResponseKeyHandler;
FOUNDATION_EXPORT NSString *const UCARHttpResponseKeyHandlerServer;
FOUNDATION_EXPORT NSString *const UCARHttpResponseKeyHandlerClient;
FOUNDATION_EXPORT NSString *const UCARHttpResponseKeyHandlerUser;

FOUNDATION_EXPORT NSString *const UCARURLHttpDNS;
