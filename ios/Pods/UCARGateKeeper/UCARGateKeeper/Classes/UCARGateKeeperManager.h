//
//  UCARGateKeeper.h
//  GateKeeper
//
//  Created by linux on 16/2/18.
//  Copyright © 2016年 Arlen. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 取值回调

 @param isOpen 是否开启
 */
typedef void (^GateKeeperValueFetchCompletionHandler)(BOOL isOpen);

/**
 UCARGateKeeperManager
 @discussion http://wiki.10101111.com/pages/viewpage.action?pageId=9962508
 @note 配置链接: http://gatekeepertest.10101111.com admin/gk_admin
 */
@interface UCARGateKeeperManager : NSObject

/**
 初始化

 @param configFileName 配置文件名，直接从mainBundle中读取
 @param appVersion App版本
 @param cid API版本
 */
+ (void)initServiceWithConfig:(NSString *)configFileName appVersion:(NSString *)appVersion cid:(NSString *)cid;

/**
 获取开关值

 @param key key值
 @param completionHandler 完成回调
 @discussion handler为同步执行
 */
+ (void)fetchGateKeeperValueForKey:(NSString *)key
                 completionHandler:(GateKeeperValueFetchCompletionHandler)completionHandler;

@end
