//
//  UCARKeyChainConfig.h
//  TTKeyChain
//
//  Created by 闫子阳 on 2018/8/30.
//  Copyright © 2018年 闫子阳. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UCARKeychainQuerySynchronizationMode)
{
    UCARKeychainQuerySynchronizationModeAny, // 可获取同步和不同步的数据
    UCARKeychainQuerySynchronizationModeNo, // 获取不同步的数据
    UCARKeychainQuerySynchronizationModeYes // 不同设备间可进行同步，设置accessibilityType时不能用ThisDeviceOnly后缀
};

typedef NS_ENUM(NSInteger, UCARKeyChainStoreType)
{
    UCARKeyChainStoreTypeString = 0,
    UCARKeyChainStoreTypeData,
    UCARKeyChainStoreTypeDict
};

typedef NS_ENUM(OSStatus, UCARKeychainErrorCode)
{
    /** Some of the arguments were invalid. */
    UCARKeychainErrorBadArguments = -1001,
};

@interface UCARKeyChainConfig : NSObject

/**
 关联的服务类型，默认为com.ucar.keychain
 可不设置，设置时增删改查必须保持一致
 */
@property (nonatomic, copy) NSString *service;

/**
 存储数据对应的key
 */
@property (nonatomic, copy) NSString *key;

/**
 需要存储的值
 data: json串
 */
@property (nonatomic, copy) NSString *value;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSDictionary *dict;

/**
 设备间的同步模式，通过iCloud。默认为UCARKeychainQuerySynchronizationModeAny
 设置此属性为UCARKeychainQuerySynchronizationModeYes或UCARKeychainQuerySynchronizationModeNo时，
 增删改查必须设置一致才能获取到值
 */
@property (nonatomic, assign) UCARKeychainQuerySynchronizationMode synchronizationMode;

/**
 安全机制，默认为kSecAttrAccessibleWhenUnlocked，只有解锁状态能存取数据，一般不需要修改
 当app有后台更新机制时，可设置为kSecAttrAccessibleAfterFirstUnlock
 以上两种方式都可以进行设备间的同步，需设置synchronizationMode = UCARKeychainQuerySynchronizationModeYes
 */
@property (nonatomic, assign) CFTypeRef accessibilityType;

/**
 不同app间共享数据的标识，设置为keychain sharing中的值，不同app之间的值必须相同，也可不设置
 */
@property (nonatomic, copy) NSString *accessGroup;

/**
 存储的类型
 */
@property (nonatomic, assign) UCARKeyChainStoreType storeType;

+ (instancetype)defaultConfig;

@end
