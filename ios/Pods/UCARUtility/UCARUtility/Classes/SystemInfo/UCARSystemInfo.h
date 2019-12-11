//
//  Utility.h
//  AutoRental
//
//  Created by sanzhang on 1/17/14.
//  Copyright (c) 2014 zuche. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const UCARSystemInfoNetType2G;
FOUNDATION_EXPORT NSString *const UCARSystemInfoNetType3G;
FOUNDATION_EXPORT NSString *const UCARSystemInfoNetType4G;
FOUNDATION_EXPORT NSString *const UCARSystemInfoNetTypeUnknown;


/**
 系统信息
 */
@interface UCARSystemInfo : NSObject


/**
 get idfv

 @return idfv string
 @discussion 该值必能取到
 */
+ (NSString *)idfvString;


/**
 get idfa

 @return idfa string
 @discussion 该值在打开“限制广告追踪”时会取到一堆000
 */
+ (NSString *)idfaString;


/**
 获取系统版本

 @return a float version number
 @discussion 8.0 -> 8.0, 9.0.1 -> 9.01, 10.1.3 -> 10.13
 */
+ (float)getIOSVersion;


/**
 获取机型

 @return 机型
 @discussion iPhone6, iPhoneX, iPhoneXR
 */
+ (NSString *)getCurrentDeviceModel;


/**
 是否越狱

 @return jailbreak status
 */
+ (BOOL)isJailbreak;


/**
 获取运营商

 @return 运营商名称
 */
+ (NSString *)carrierName;


/**
 获取数据信号类型

 @return 数据信号类型，2G/3G/4G
 */
+ (NSString *)cellularType;


/**
 获取 bundle name
 
 @return bundle name
 */
+ (NSString *)appBundleName;


/**
 获取 display name

 @return display name
 */
+ (NSString *)appDisplayName;


/**
 获取 bundle id

 @return bundle id
 */
+ (NSString *)appBundleIdentifier;

/**
 获取 app 版本号

 @return app 版本号
 @discussion 1.0.0, 3.1.3
 */
+ (NSString *)appVersion;

/**
 获取 app 版本号
 
 @return app 版本号
 @discussion 100, 313
 */
+ (NSString *)appVersionClean;

@end
