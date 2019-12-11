//
//  UCARKeyChainManager.m
//  TTKeyChain
//
//  Created by 闫子阳 on 2018/8/30.
//  Copyright © 2018年 闫子阳. All rights reserved.
//

#import "UCARKeyChainManager.h"

NSString* const kUCARKeyChainDeviceToken = @"ios_device_token";
NSString* const kUCARKeyChainShredDeviceToken = @"ios_shared_device_token";
NSString* const kUCARSharedKeyChianGroup = @"com.szzc.shared";

@interface UCARKeyChainManager ()

@property (nonatomic, strong) UCARKeyChainConfig *config;
@property (nonatomic, strong) NSData *encodeData;

@end

@implementation UCARKeyChainManager

#pragma mark - public

// 获取team id
+ (NSString *)getTeamId {
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:@"ucar_service" forKey:(__bridge id)kSecAttrService];
    [query setObject:@"ucar_team_id" forKey:(__bridge id)kSecAttrAccount];
    
    // 是否返回存储的Item的query属性字典，包括自定义设置的和系统默认取到的
    // 主要用于获取默认的kSecAttrAccessGroup值
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    
    OSStatus status = 0;
    CFDictionaryRef result = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if(status == errSecItemNotFound) {
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    }
    
    if (status != errSecSuccess) {
        return @"";
    }
    
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge id)kSecAttrAccessGroup];
    NSArray *components = [accessGroup componentsSeparatedByString:@"."];
    NSString *teamId = [[components objectEnumerator] nextObject];
    
    CFRelease(result);
    
    return teamId;
}

+ (BOOL)addValue:(NSString *)value key:(NSString *)key error:(NSError *__autoreleasing *)error
{
    UCARKeyChainConfig *config = [UCARKeyChainConfig defaultConfig];
    config.value = value;
    config.key = key;
    config.storeType = UCARKeyChainStoreTypeString;
    
    return [self addDataWithConfig:config error:error];
}

+ (BOOL)addData:(NSData *)data key:(NSString *)key error:(NSError *__autoreleasing *)error
{
    UCARKeyChainConfig *config = [UCARKeyChainConfig defaultConfig];
    config.data = data;
    config.key = key;
    config.storeType = UCARKeyChainStoreTypeData;
    
    return [self addDataWithConfig:config error:error];
}

+ (BOOL)addDict:(NSDictionary *)dict key:(NSString *)key error:(NSError *__autoreleasing *)error
{
    UCARKeyChainConfig *config = [UCARKeyChainConfig defaultConfig];
    config.dict = dict;
    config.key = key;
    config.storeType = UCARKeyChainStoreTypeDict;
    
    return [self addDataWithConfig:config error:error];
}

+ (BOOL)updateValue:(NSString *)value key:(NSString *)key error:(NSError *__autoreleasing *)error
{
    UCARKeyChainConfig *config = [UCARKeyChainConfig defaultConfig];
    config.value = value;
    config.key = key;
    config.storeType = UCARKeyChainStoreTypeString;
    
    return [self updateDataWithConfig:config error:error];
}

+ (BOOL)updateData:(NSData *)data key:(NSString *)key error:(NSError *__autoreleasing *)error
{
    UCARKeyChainConfig *config = [UCARKeyChainConfig defaultConfig];
    config.data = data;
    config.key = key;
    config.storeType = UCARKeyChainStoreTypeData;
    
    return [self updateDataWithConfig:config error:error];
}

+ (BOOL)updateDict:(NSDictionary *)dict key:(NSString *)key error:(NSError *__autoreleasing *)error
{
    UCARKeyChainConfig *config = [UCARKeyChainConfig defaultConfig];
    config.dict = dict;
    config.key = key;
    config.storeType = UCARKeyChainStoreTypeDict;
    
    return [self updateDataWithConfig:config error:error];
}

+ (NSData *)getDataWithKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    UCARKeyChainConfig *config = [UCARKeyChainConfig defaultConfig];
    config.key = key;
    config.storeType = UCARKeyChainStoreTypeData;
    
    return [self getDataWithConfig:config error:error];
}

+ (NSString *)getValueWithKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    UCARKeyChainConfig *config = [UCARKeyChainConfig defaultConfig];
    config.key = key;
    config.storeType = UCARKeyChainStoreTypeString;
    
    return [self getDataWithConfig:config error:error];
}

+ (NSDictionary *)getDictWithKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    UCARKeyChainConfig *config = [UCARKeyChainConfig defaultConfig];
    config.key = key;
    config.storeType = UCARKeyChainStoreTypeDict;
    
    return [self getDataWithConfig:config error:error];
}

+ (BOOL)deleteDataWithKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    UCARKeyChainConfig *config = [UCARKeyChainConfig defaultConfig];
    config.key = key;
    
    return [self deleteDataWithConfig:config error:error];
}

+ (BOOL)addDataWithConfig:(UCARKeyChainConfig *)config error:(NSError **)error
{
    UCARKeyChainManager *manager = [[UCARKeyChainManager alloc] init];
    manager.config = config;
    
    OSStatus status = UCARKeychainErrorBadArguments;
    if (!manager.config.service || !manager.config.key || !manager.encodeData) {
        if (error) {
            *error = [self errorWithCode:status];
        }
        return NO;
    }
    
    NSMutableDictionary *query = [manager query];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, nil);
    if(status == errSecItemNotFound) {
        [query setObject:manager.encodeData forKey:(__bridge id)kSecValueData];
        if (manager.config.accessibilityType) {
            [query setObject:(__bridge id)manager.config.accessibilityType forKey:(__bridge id)kSecAttrAccessible];
        }
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    }
    
    if (status != errSecSuccess && error != NULL) {
        *error = [self errorWithCode:status];
    }
    
    return (status == errSecSuccess);
}

+ (BOOL)updateDataWithConfig:(UCARKeyChainConfig *)config error:(NSError **)error
{
    UCARKeyChainManager *manager = [[UCARKeyChainManager alloc] init];
    manager.config = config;
    
    OSStatus status = UCARKeychainErrorBadArguments;
    if (!manager.config.service || !manager.config.key || !manager.encodeData) {
        if (error) {
            *error = [self errorWithCode:status];
        }
        return NO;
    }
    
    NSMutableDictionary *query = nil;
    NSMutableDictionary *searchQuery = [manager query];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)searchQuery, nil);
    if (status == errSecSuccess) {
        query = [[NSMutableDictionary alloc] init];
        [query setObject:manager.encodeData forKey:(__bridge id)kSecValueData];
        if (manager.config.accessibilityType) {
            [query setObject:(__bridge id)manager.config.accessibilityType forKey:(__bridge id)kSecAttrAccessible];
        }
        status = SecItemUpdate((__bridge CFDictionaryRef)(searchQuery), (__bridge CFDictionaryRef)(query));
    }
    
    if (status != errSecSuccess && error != NULL) {
        *error = [self errorWithCode:status];
    }
    return (status == errSecSuccess);
}

+ (id)getDataWithConfig:(UCARKeyChainConfig *)config error:(NSError **)error
{
    UCARKeyChainManager *manager = [[UCARKeyChainManager alloc] init];
    manager.config = config;
    
    OSStatus status = UCARKeychainErrorBadArguments;
    if (!manager.config.service || !manager.config.key) {
        if (error) {
            *error = [self errorWithCode:status];
        }
    }
    
    CFTypeRef result = NULL;
    NSMutableDictionary *query = [manager query];
    [query setObject:@YES forKey:(__bridge id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
    if (status != errSecSuccess) {
        if (error) {
            *error = [self errorWithCode:status];
        }
    }
    
    manager.encodeData = (__bridge_transfer NSData *)result;
    switch (config.storeType) {
        case UCARKeyChainStoreTypeString:
        {
            return [[NSString alloc] initWithData:manager.encodeData encoding:NSUTF8StringEncoding];
        }
            break;
        case UCARKeyChainStoreTypeData:
        {
            return manager.encodeData;
        }
            break;
        case UCARKeyChainStoreTypeDict:
        {
            if (manager.encodeData) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:manager.encodeData options:NSJSONReadingMutableLeaves error:nil];
                return dict;
            } else {
                return nil;
            }
        }
            break;
            
        default:
            return nil;
            break;
    }
}

+ (BOOL)deleteDataWithConfig:(UCARKeyChainConfig *)config error:(NSError **)error
{
    UCARKeyChainManager *manager = [[UCARKeyChainManager alloc] init];
    manager.config = config;
    
    OSStatus status = UCARKeychainErrorBadArguments;
    if (!manager.config.service || !manager.config.key) {
        if (error) {
            *error = [self errorWithCode:status];
        }
    }
    
    NSMutableDictionary *query = [manager query];
    status = SecItemDelete((__bridge CFDictionaryRef)query);
    
    if (status != errSecSuccess && error != NULL) {
        *error = [self errorWithCode:status];
    }
    
    return (status == errSecSuccess);
}

#pragma mark - Private

- (NSMutableDictionary *)query
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    [dictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    if (self.config.service) {
        [dictionary setObject:self.config.service forKey:(__bridge id)kSecAttrService];
    }
    
    if (self.config.key) {
        [dictionary setObject:self.config.key forKey:(__bridge id)kSecAttrAccount];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    if (self.config.accessGroup) {
        [dictionary setObject:self.config.accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif
    
    // 同步模式
    id value;
    switch (self.config.synchronizationMode) {
        case UCARKeychainQuerySynchronizationModeNo: {
            value = @NO;
            break;
        }
        case UCARKeychainQuerySynchronizationModeYes: {
            value = @YES;
            break;
        }
        case UCARKeychainQuerySynchronizationModeAny: {
            value = (__bridge id)(kSecAttrSynchronizableAny);
            break;
        }
    }
    
    [dictionary setObject:value forKey:(__bridge id)(kSecAttrSynchronizable)];
    
    return dictionary;
}

- (void)setConfig:(UCARKeyChainConfig *)config
{
    _config = config;
    
    switch (config.storeType) {
        case UCARKeyChainStoreTypeString:
        {
            if (config.value) {
                self.encodeData = [config.value dataUsingEncoding:NSUTF8StringEncoding];
            }
        }
            break;
        case UCARKeyChainStoreTypeData:
        {
            if (config.data) {
                self.encodeData = config.data;
            }
        }
            break;
        case UCARKeyChainStoreTypeDict:
        {
            if (config.dict) {
                self.encodeData = [NSJSONSerialization dataWithJSONObject:config.dict options:NSJSONWritingPrettyPrinted error:nil];
            }
        }
            break;
        default:
            break;
    }
}

+ (NSError *)errorWithCode:(OSStatus)code
{
    NSString *message = nil;
    switch (code) {
        case UCARKeychainErrorBadArguments: {
            message = @"Some of the arguments were invalid";
            break;
        }
        case errSecUnimplemented: {
            message = @"Function or operation not implemented";
            break;
        }
        case errSecParam: {
            message = @"One or more parameters passed to a function were not valid";
            break;
        }
        case errSecAllocate: {
            message = @"Failed to allocate memory";
            break;
        }
        case errSecNotAvailable: {
            message = @"No keychain is available. You may need to restart your computer";
            break;
        }
        case errSecDuplicateItem: {
            message = @"The specified item already exists in the keychain";
            break;
        }
        case errSecItemNotFound: {
            message = @"The specified item could not be found in the keychain";
            break;
        }
        case errSecInteractionNotAllowed: {
            message = @"User interaction is not allowed";
            break;
        }
        case errSecDecode: {
            message = @"Unable to decode the provided data";
            break;
        }
        case errSecAuthFailed: {
            message = @"The user name or passphrase you entered is not correct";
            break;
        }
        default: {
            message = @"Refer to SecBase.h for description";
            break;
        }
    }
    
    NSDictionary *userInfo = nil;
    if (message) {
        userInfo = @{ NSLocalizedDescriptionKey : message };
    }
    return [NSError errorWithDomain:@"com.ucaroffes.ucarkeychain" code:code userInfo:userInfo];
}

@end
