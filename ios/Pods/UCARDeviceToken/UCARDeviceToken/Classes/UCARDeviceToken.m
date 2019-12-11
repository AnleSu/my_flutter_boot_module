//
//  UCARDeviceToken.m
//  UCARDeviceToken
//
//  Created by linux on 2018/12/13.
//

#import "UCARDeviceToken.h"
#import "UCARKeyChainManager.h"

@implementation UCARDeviceToken

+ (instancetype)sharedToken {
    static UCARDeviceToken *token = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        token = [[UCARDeviceToken alloc] init];
    });
    return token;
}

+ (NSString *)deviceUUID {
    NSString * deviceToken = [UCARDeviceToken sharedToken].customDeviceUUID;
    if (!deviceToken) {
        deviceToken = [self keyChainDeviceToken];
    }
    return deviceToken;
}

+ (NSString *)sharedDeviceUUID {
    UCARKeyChainConfig *config = [UCARKeyChainConfig defaultConfig];
    config.storeType = UCARKeyChainStoreTypeString;
    config.key = kUCARKeyChainShredDeviceToken;
    config.accessGroup = [NSString stringWithFormat:@"%@%@%@", [UCARKeyChainManager getTeamId], @".", kUCARSharedKeyChianGroup];
    
    NSError *error = nil;
    NSString *deviceToken = [UCARKeyChainManager getDataWithConfig:config error:&error];
    if (deviceToken.length == 0 || error) {
        deviceToken = [UIDevice currentDevice].identifierForVendor.UUIDString;
        config.value = deviceToken;
        [UCARKeyChainManager addDataWithConfig:config error:&error];
    }
    
    return deviceToken;
}

+ (NSString *)keyChainDeviceToken {
    NSError *error = nil;
    NSString *deviceToken = [UCARKeyChainManager getValueWithKey:kUCARKeyChainDeviceToken error:&error];
    if (!deviceToken || error || deviceToken.length < 1) {
        deviceToken = [UIDevice currentDevice].identifierForVendor.UUIDString;
        [UCARKeyChainManager addValue:deviceToken key:kUCARKeyChainDeviceToken error:nil];
    }
    return deviceToken;
}

@end
