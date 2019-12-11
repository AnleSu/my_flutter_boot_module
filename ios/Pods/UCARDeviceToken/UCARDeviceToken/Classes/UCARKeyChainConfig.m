//
//  UCARKeyChainConfig.m
//  TTKeyChain
//
//  Created by 闫子阳 on 2018/8/30.
//  Copyright © 2018年 闫子阳. All rights reserved.
//

#import "UCARKeyChainConfig.h"

@implementation UCARKeyChainConfig

+ (instancetype)defaultConfig
{
    UCARKeyChainConfig *config = [[UCARKeyChainConfig alloc] init];
    config.service = @"com.ucar.keychain";
    config.synchronizationMode = UCARKeychainQuerySynchronizationModeAny;
    config.accessibilityType = kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
    config.storeType = UCARKeyChainStoreTypeString;
    
    return config;
}

@end
