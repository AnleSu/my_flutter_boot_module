//
//  EnvConfig.h
//  UCar
//
//  Created by  zhangfenglin on 15/8/10.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const UCAREnvDev1;
FOUNDATION_EXPORT NSString *const UCAREnvDev2;
FOUNDATION_EXPORT NSString *const UCAREnvDev3;
FOUNDATION_EXPORT NSString *const UCAREnvPre;
FOUNDATION_EXPORT NSString *const UCAREnvPro;


/**
 环境配置
 */
@interface UCAREnvConfig : NSObject


/**
 初始化环境变量

 @param fileName 各环境配置文件
 @param envKey 环境
 */
+ (void)initWithConfigFileName:(NSString *)fileName envKey:(NSString *)envKey;


/**
 根据key获取配置

 @param key 具体的domain，url等
 @return config value
 @discussion
 该方法用于获取环境内的具体配置项，例如：{ "develop": {"apiDomain": "mapi.zuche.com"}} 中的 apiDomain
 */
+ (NSString *)getConfigByKey:(NSString *)key;


/**
 获取当前环境

 @return 当前环境
 */
+ (NSString *)getCurrentEnvKey;

@end
