//
//  UCARWebViewBridgeController.h
//  UCARJSBridge
//
//  Created by linux on 27/12/2017.
//  Copyright © 2017 UCar. All rights reserved.
//

#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>

//页面由app进入还是由webview进入
typedef NS_ENUM(NSInteger, UCARWebViewBridgeRouteType) {
    UCARWebViewBridgeRouteTypeNone,
    UCARWebViewBridgeRouteTypeApp,
    UCARWebViewBridgeRouteTypeHybrid
};

/**
 仅用于hybrid开发，严禁掺杂常规H5逻辑
 **/
@interface UCARWebViewBridgeController : UIViewController


/**
 default = UCARWebViewBridgeRouteTypeNone
 */
@property (nonatomic) UCARWebViewBridgeRouteType routeType;

/**
 UCARWebViewBridgeRouteTypeNone     -> url
 UCARWebViewBridgeRouteTypeApp      -> 页面key，相当于页面router，业务线无需关注具体值
 UCARWebViewBridgeRouteTypeHybrid   -> 包含路径和参数
 */
@property (nonatomic, nullable, copy) NSString *webViewPagePath;

/**
 参数，会以query形式传递给html页面，可支持dict && list嵌套。仅支持json支持的数据类型。无参数时传"@{}"
 */
@property (nonatomic, nullable, copy) NSDictionary *parameters;

/**
 subclass must overwrite the method with iOS8/iOS9+.
 */
- (void)setCustomUserAgent:(WKWebView *)webView;

/**
 must call after set webViewPagePath
 only usable when routeType = UCARWebViewBridgeRouteTypeHybrid
 */
- (void)reloadWebView;

/**
 produce requese parameters with protocol.
 */
- (NSMutableDictionary *)requestParamsForProtocol:(NSString *)protocol;

/**
 produce success response result.
 */
- (NSMutableDictionary *)successResponse;

/**
 produce failed response result.
 */
- (NSMutableDictionary *)failResponse;

/**
 native call JS hander
 params:request JS parameters
 callback:JS call back method.
 */
- (void)callHandler:(NSDictionary *)params callback:(WVJBResponseCallback)callback;

@end
