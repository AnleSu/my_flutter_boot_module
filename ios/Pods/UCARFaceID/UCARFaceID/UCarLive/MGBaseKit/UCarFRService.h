//
//  UCarFRService.h
//  MGBaseKit
//
//  Created by huyujin on 16/10/12.
//  Copyright © 2016年 megvii. All rights reserved.

// ucar face recognition

#import <Foundation/Foundation.h>

@interface UCarFRService : NSObject

@property (nonatomic, readonly, copy) NSString *appId;
@property (nonatomic, readonly, copy) NSString *appToken;

@property (nonatomic, assign)         BOOL      debugMode; ///< 调试模式：YES 正式环境：NO

+ (instancetype)sharedInstance;

/**
 *  初始化UCarFRService
 *
 *  @param appId 注册UCarFR分配的appid
 *  @param appToken 注册UCarFR分配的appToken
 */

- (void)startWithAppId:(NSString *)appId appToken:(NSString *)appToken;

/**
 *  SDK 版本信息
 *
 *  @return
 */
+ (NSString *)sdkVersion;

@end
