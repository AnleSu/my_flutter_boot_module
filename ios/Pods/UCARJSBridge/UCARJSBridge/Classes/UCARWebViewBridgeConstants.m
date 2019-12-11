//
//  UCARWebViewBridgeConstants.m
//  UCARJSBridge
//
//  Created by linux on 15/01/2018.
//  Copyright © 2018 UCar. All rights reserved.
//

#import "UCARWebViewBridgeConstants.h"

NSString * const UCARWebViewBridgeNotiKeyLoginSuccess = @"UCARWebViewBridgeNotiKeyLoginSuccess";

NSString * const UCARWebViewBridgeUserDefaultFolderNameKey = @"UCARWebViewBridgeUserDefaultFolderNameKey";
NSString * const UCARWebViewBridgeUserDefaultFolderVersionKey = @"UCARWebViewBridgeUserDefaultFolderVersionKey";
NSString * const UCARWebViewBridgeUserDefaultVersionKey = @"UCARWebViewBridgeUserDefaultVersionKey";

NSString * const UCARWebviewBridgeUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS %@ like Mac OS X) AppleWebKit/604.4.7 (KHTML, like Gecko) Mobile/15C153 UCARHybridWebView-iOS-%@-%@";
NSString * const UCARWebviewBridgeUCARJSCallNative = @"UCARJSCallNative";
NSString * const UCARWebviewBridgeUCARNativeCallJS = @"UCARNativeCallJS";

NSString * const UCARWebviewBridgeRequestKeyProtocol = @"protocol";
NSString * const UCARWebviewBridgeRequestKeyParameters = @"parameters";

//UCARJSCallNative
NSString * const UCARWebviewBridgeProtocolHttp = @"http";
NSString * const UCARWebviewBridgeProtocolMonitor = @"monitor";
NSString * const UCARWebviewBridgeProtocolRoute = @"route";
NSString * const UCARWebviewBridgeProtocolRoutePop = @"popView";
NSString * const UCARWebviewBridgeProtocolRouteHome = @"goHomePage";
NSString * const UCARWebviewBridgeProtocolStorage = @"storage";
NSString * const UCARWebviewBridgeProtocolAlbum = @"album";
NSString * const UCARWebviewBridgeProtocolLocation = @"location";
NSString * const UCARWebviewBridgeProtocolGallery = @"gallery";
NSString * const UCARWebviewBridgeProtocolDeviceId = @"deviceId";
NSString * const UCARWebviewBridgeProtocolCheckLogin = @"checkLogin";
NSString * const UCARWebviewBridgeProtocolLogin = @"login";
NSString * const UCARWebviewBridgeProtocolShowQRCode = @"showQRCode";
NSString * const UCARWebviewBridgeProtocolShare = @"share";
NSString * const UCARWebviewBridgeProtocolNewShare = @"newShare";
NSString * const UCARWebviewBridgeProtocolShowPay = @"showPay";
NSString * const UCARWebviewBridgeProtocolNewShowPay = @"newShowPay";//新的调起支付协议
NSString * const UCARWebviewBridgeProtocolShowAddressBook = @"showAddressBook";
NSString * const UCARWebviewBridgeProtocolGetUid = @"getUid";
NSString * const UCARWebviewBridgeProtocolWechatDonate = @"wechatDonate";
NSString * const UCARWebviewBridgeProtocolUpdateUI = @"updateUI";
NSString * const UCARWebviewBridgeProtocolFaceRecognition = @"faceID";
NSString * const UCARWebviewBridgeProtocolNextStep = @"nextStep";

//UCARNativeCallJS
NSString * const UCARWebviewBridgeProtocolPush = @"push";
NSString * const UCARWebviewBridgeProtocolReload = @"reload";
NSString * const UCARWebviewBridgeProtocolPostPayCouponsResult = @"postPayResult";
NSString * const UCARWebviewBridgeProtocolNewPostPayResult = @"newPostPayResult";//新的通知web支付结果协议

NSString * const UCARWebviewBridgeProtocolRouteHostApp = @"UCARapp";
NSString * const UCARWebviewBridgeProtocolRouteHostWebView = @"UCARwebview";

NSString * const UCARWebviewBridgeResponseKeyStatus = @"status";
NSString * const UCARWebviewBridgeResponseKeySuccess = @"success";
NSString * const UCARWebviewBridgeResponseKeyError = @"error";
NSString * const UCARWebviewBridgeResponseKeyData = @"data";

NSString * const UCARWebviewBridgeProtocolFaceRecognitionResult = @"faceIDResult";
