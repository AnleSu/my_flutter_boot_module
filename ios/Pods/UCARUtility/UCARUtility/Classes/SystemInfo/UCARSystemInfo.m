//
//  Utility.m
//  AutoRental
//
//  Created by sanzhang on 1/17/14.
//  Copyright (c) 2014 zuche. All rights reserved.
//

#import "UCARSystemInfo.h"
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

NSString *const UCARSystemInfoNetType2G = @"2G";
NSString *const UCARSystemInfoNetType3G = @"3G";
NSString *const UCARSystemInfoNetType4G = @"4G";
NSString *const UCARSystemInfoNetTypeUnknown = @"unknown";

@implementation UCARSystemInfo

+ (NSString *)idfvString {
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

+ (NSString *)idfaString {
    return [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString;
}

+ (float)getIOSVersion {
    NSString *version = [[UIDevice currentDevice] systemVersion];
    NSRange range = [version rangeOfString:@"."];
    NSString *subStr = [version substringFromIndex:range.location + range.length];
    subStr = [subStr stringByReplacingOccurrencesOfString:@"." withString:@""];
    version = [[version substringToIndex:range.location + range.length] stringByAppendingString:subStr];
    return [version floatValue];
}

+ (NSString *)getCurrentDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);

    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([platform isEqualToString:@"iPhone1,1"])
        return @"iPhone2G";
    if ([platform isEqualToString:@"iPhone1,2"])
        return @"iPhone3G";

    if ([platform isEqualToString:@"iPhone2,1"])
        return @"iPhone3GS";

    if ([platform isEqualToString:@"iPhone3,1"])
        return @"iPhone4";
    if ([platform isEqualToString:@"iPhone3,2"])
        return @"iPhone4";
    if ([platform isEqualToString:@"iPhone3,3"])
        return @"iPhone4";

    if ([platform isEqualToString:@"iPhone4,1"])
        return @"iPhone4S";
    if ([platform isEqualToString:@"iPhone4,2"])
        return @"iPhone4S";
    if ([platform isEqualToString:@"iPhone4,3"])
        return @"iPhone4S";

    if ([platform isEqualToString:@"iPhone5,1"])
        return @"iPhone5";
    if ([platform isEqualToString:@"iPhone5,2"])
        return @"iPhone5";
    if ([platform isEqualToString:@"iPhone5,3"])
        return @"iPhone5C";
    if ([platform isEqualToString:@"iPhone5,4"])
        return @"iPhone5C";

    if ([platform isEqualToString:@"iPhone6,1"])
        return @"iPhone5S";
    if ([platform isEqualToString:@"iPhone6,2"])
        return @"iPhone5S";

    if ([platform isEqualToString:@"iPhone7,1"])
        return @"iPhone6Plus";
    if ([platform isEqualToString:@"iPhone7,2"])
        return @"iPhone6";

    if ([platform isEqualToString:@"iPhone8,1"])
        return @"iPhone6S";
    if ([platform isEqualToString:@"iPhone8,2"])
        return @"iPhone6SPlus";
    if ([platform isEqualToString:@"iPhone8,4"])
        return @"iPhoneSE";

    if ([platform isEqualToString:@"iPhone9,1"])
        return @"iPhone7";
    if ([platform isEqualToString:@"iPhone9,3"])
        return @"iPhone7";
    if ([platform isEqualToString:@"iPhone9,2"])
        return @"iPhone7Plus";
    if ([platform isEqualToString:@"iPhone9,4"])
        return @"iPhone7";

    if ([platform isEqualToString:@"iPhone9,1"])
        return @"iPhone7";
    if ([platform isEqualToString:@"iPhone9,3"])
        return @"iPhone7";
    if ([platform isEqualToString:@"iPhone9,2"])
        return @"iPhone7Plus";
    if ([platform isEqualToString:@"iPhone9,4"])
        return @"iPhone7";

    if ([platform isEqualToString:@"iPhone10,1"])
        return @"iPhone8";
    if ([platform isEqualToString:@"iPhone10,2"])
        return @"iPhone8Plus";
    if ([platform isEqualToString:@"iPhone10,3"])
        return @"iPhoneX";
    if ([platform isEqualToString:@"iPhone10,4"])
        return @"iPhone8";
    if ([platform isEqualToString:@"iPhone10,5"])
        return @"iPhone8Plus";
    if ([platform isEqualToString:@"iPhone10,6"])
        return @"iPhoneX";

    if ([platform isEqualToString:@"iPhone11,2"])
        return @"iPhoneXS";
    if ([platform isEqualToString:@"iPhone11,4"])
        return @"iPhoneXSMax";
    if ([platform isEqualToString:@"iPhone11,6"])
        return @"iPhoneXSMax";
    if ([platform isEqualToString:@"iPhone11,8"])
        return @"iPhoneXR";

    if ([platform isEqualToString:@"i386"])
        return @"iPhoneSimulator";
    if ([platform isEqualToString:@"x86_64"])
        return @"iPhoneSimulator";

    return platform;
}

+ (BOOL)isJailbreak {
    return [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"];
}

//=======================
+ (CTCarrier *)carrier {
    return [[CTTelephonyNetworkInfo alloc] init].subscriberCellularProvider;
}
+ (NSString *)carrierName {
    return [UCARSystemInfo carrier].carrierName;
}

+ (NSString *)cellularType {
    NSString *netType = [[CTTelephonyNetworkInfo alloc] init].currentRadioAccessTechnology;
    if (!netType) {
        return UCARSystemInfoNetTypeUnknown;
    }
    //先判断4G
    if ([netType isEqualToString:CTRadioAccessTechnologyLTE])
        return UCARSystemInfoNetType4G;
    if ([netType isEqualToString:CTRadioAccessTechnologyGPRS])
        return UCARSystemInfoNetType2G;
    if ([netType isEqualToString:CTRadioAccessTechnologyEdge])
        return UCARSystemInfoNetType2G;
    if ([netType isEqualToString:CTRadioAccessTechnologyWCDMA])
        return UCARSystemInfoNetType3G;
    if ([netType isEqualToString:CTRadioAccessTechnologyHSDPA])
        return UCARSystemInfoNetType3G;
    if ([netType isEqualToString:CTRadioAccessTechnologyHSUPA])
        return UCARSystemInfoNetType3G;
    if ([netType isEqualToString:CTRadioAccessTechnologyCDMA1x])
        return UCARSystemInfoNetType2G;
    // dont know
    if ([netType isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0])
        return UCARSystemInfoNetType3G;
    // dont know
    if ([netType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA])
        return UCARSystemInfoNetType3G;
    // dont know
    if ([netType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB])
        return UCARSystemInfoNetType3G;
    // what is this
    if ([netType isEqualToString:CTRadioAccessTechnologyeHRPD])
        return UCARSystemInfoNetType3G;

    return UCARSystemInfoNetTypeUnknown;
}

+ (NSString *)appBundleName {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
}

+ (NSString *)appDisplayName {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
}

+ (NSString *)appBundleIdentifier {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"];
}

// 0.1.0
+ (NSString *)appVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

// 100
+ (NSString *)appVersionClean {
    NSString *version = [self appVersion];
    return [version stringByReplacingOccurrencesOfString:@"." withString:@""];
}

@end
