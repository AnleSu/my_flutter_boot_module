//
//  UCARWebViewBridgeConstants.h
//  UCARJSBridge
//
//  Created by linux on 15/01/2018.
//  Copyright © 2018 UCar. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const UCARWebViewBridgeNotiKeyLoginSuccess;

//存储压缩包解压后的名字
FOUNDATION_EXPORT NSString * const UCARWebViewBridgeUserDefaultFolderNameKey;
//存储压缩包解压后的路径前缀，此值为app版本号
FOUNDATION_EXPORT NSString * const UCARWebViewBridgeUserDefaultFolderVersionKey;
//存储压缩包的版本
FOUNDATION_EXPORT NSString * const UCARWebViewBridgeUserDefaultVersionKey;

FOUNDATION_EXPORT NSString * const UCARWebviewBridgeUserAgent;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeUCARJSCallNative;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeUCARNativeCallJS;

FOUNDATION_EXPORT NSString * const UCARWebviewBridgeRequestKeyProtocol;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeRequestKeyParameters;

//UCARJSCallNative
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolHttp;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolMonitor;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolRoute;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolRoutePop;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolRouteHome;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolStorage;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolAlbum;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolLocation;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolGallery;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolDeviceId;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolCheckLogin;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolLogin;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolShowQRCode;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolShare;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolNewShare;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolShowPay;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolNewShowPay;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolShowAddressBook;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolGetUid;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolWechatDonate;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolUpdateUI;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolFaceRecognition;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolNextStep;

//UCARNativeCallJS
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolPush;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolReload;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolPostPayCouponsResult;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolNewPostPayResult;

FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolRouteHostApp;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolRouteHostWebView;


FOUNDATION_EXPORT NSString * const UCARWebviewBridgeResponseKeyStatus;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeResponseKeySuccess;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeResponseKeyError;
FOUNDATION_EXPORT NSString * const UCARWebviewBridgeResponseKeyData;

FOUNDATION_EXPORT NSString * const UCARWebviewBridgeProtocolFaceRecognitionResult;
