//
//  UCARKeyChainManager.h
//  TTKeyChain
//
//  Created by 闫子阳 on 2018/8/30.
//  Copyright © 2018年 闫子阳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCARKeyChainConfig.h"

extern NSString* const kUCARKeyChainDeviceToken;

// 共享的deviceToken取值时的key
extern NSString* const kUCARKeyChainShredDeviceToken;

// 共享数据时的keychain group，与team id拼接成access group
extern NSString* const kUCARSharedKeyChianGroup;

@interface UCARKeyChainManager : NSObject

#pragma mark - 获取team Id

+ (NSString *)getTeamId;

#pragma mark - 快速增删改查方法

/**
 没有数据时存储新数据
 
 @param value 需要存储的数据 data: json串
 @param key 对应的key值
 @param error 错误
 @return 是否保存成功
 */
+ (BOOL)addValue:(NSString *)value key:(NSString *)key error:(NSError **)error;
+ (BOOL)addData:(NSData *)data key:(NSString *)key error:(NSError **)error;
+ (BOOL)addDict:(NSDictionary *)dict key:(NSString *)key error:(NSError **)error;

/**
 有存储数据时更新数据

 @param value 需要更新的数据
 @param key 对应的key值
 @param error 错误
 @return 是否更新成功
 */
+ (BOOL)updateValue:(NSString *)value key:(NSString *)key error:(NSError **)error;
+ (BOOL)updateData:(NSData *)data key:(NSString *)key error:(NSError **)error;
+ (BOOL)updateDict:(NSDictionary *)dict key:(NSString *)key error:(NSError **)error;

/**
 获取存储的数据

 @param key 对应的key值
 @param error 错误
 @return 存储的数据
 */
+ (NSString *)getValueWithKey:(NSString *)key error:(NSError **)error;
+ (NSData *)getDataWithKey:(NSString *)key error:(NSError **)error;
+ (NSDictionary *)getDictWithKey:(NSString *)key error:(NSError **)error;

/**
 删除存储的数据
 
 @param key 对应的key值
 @param error 错误
 @return 是否删除成功
 */
+ (BOOL)deleteDataWithKey:(NSString *)key error:(NSError **)error;

#pragma mark - 可配置的增删改查方法

/**
 @param config 一些配置属性
 @param error 错误
 */
+ (BOOL)addDataWithConfig:(UCARKeyChainConfig *)config error:(NSError **)error;
+ (BOOL)updateDataWithConfig:(UCARKeyChainConfig *)config error:(NSError **)error;
+ (id)getDataWithConfig:(UCARKeyChainConfig *)config error:(NSError **)error;
+ (BOOL)deleteDataWithConfig:(UCARKeyChainConfig *)config error:(NSError **)error;

@end
