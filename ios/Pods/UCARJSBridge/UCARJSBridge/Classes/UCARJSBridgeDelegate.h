//
//  UCARJSBridgeDelegate.h
//  Expecta
//
//  Created by 陈辉 on 2018/7/27.
//

#import <Foundation/Foundation.h>
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>

@protocol UCARJSBridgeDelegate <NSObject>

// JS Call Native
- (void)callNativeRoute:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeRoutePop:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeHttp:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeMonitor:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeRouteHome:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeStorage:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeAlbum:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeLocation:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeGallery:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeDeviceId:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeCheckLogin:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeLogin:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeShowQRCode:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeShare:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativePay:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeAddressBook:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeFaceRecognition:(NSDictionary *)data callback:(WVJBResponseCallback)callback;
- (void)callNativeNextStep:(NSDictionary *)data callback:(WVJBResponseCallback)callback;

// Native Call JS
- (void)callJSPush:(NSDictionary *)data;
- (void)callJSReloadCurrentPage;
- (void)callJSPayResult;
- (void)callJSFaceRecognitionResult;

@end
