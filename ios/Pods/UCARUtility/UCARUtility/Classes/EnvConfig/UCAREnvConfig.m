//
//  EnvConfig.m
//  UCar
//
//  Created by  zhangfenglin on 15/8/10.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import "UCAREnvConfig.h"

NSString *const UCAREnvDev1 = @"develop";
NSString *const UCAREnvDev2 = @"develop2";
NSString *const UCAREnvDev3 = @"develop3";
NSString *const UCAREnvPre = @"preproduct";
NSString *const UCAREnvPro = @"product";

@interface UCAREnvConfig ()

@property (nonatomic) NSString *currentEnvKey;
@property (nonatomic) NSDictionary *currentConfig;

@end

@implementation UCAREnvConfig

+ (instancetype)shared {
    static id sharedUtil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedUtil = [[self alloc] init];
    });
    return sharedUtil;
}

+ (void)initWithConfigFileName:(NSString *)fileName envKey:(NSString *)envKey {
    [[self shared] initWithConfigFileName:fileName envKey:envKey];
}

+ (NSString *)getConfigByKey:(NSString *)key {
    return [UCAREnvConfig shared].currentConfig[key];
}

+ (NSString *)getCurrentEnvKey {
    return [[UCAREnvConfig shared] currentEnvKey];
}

- (void)initWithConfigFileName:(NSString *)fileName envKey:(NSString *)envKey {
    _currentEnvKey = [envKey copy];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSDictionary *allConfigs = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    _currentConfig = allConfigs[_currentEnvKey];
}

@end
