//
//  UCARPushEngine.h
//  UCARPushDemo
//
//  Created by North on 10/27/16.
//  Copyright © 2016 North. All rights reserved.
//

#import "UCARSocketPacket.h"
#import <Foundation/Foundation.h>

/**
 UCARPushEngineDelegate
 */
@protocol UCARPushEngineDelegate <NSObject>

@required

/**
 push通道建立连接
 */
- (void)socketDidConnect;

/**
 push通道断开
 */
- (void)socketDidDisconnect;

/**
 心跳成功
 */
- (void)heartbeatSuccess;

/**
 收到push消息

 @param packet push包
 */
- (void)receivePushPacket:(nonnull UCARSocketPacket *)packet;

@end

/**
 UCARPushEngine，负责与push server通信
 */
@interface UCARPushEngine : NSObject

/**
 delegate
 */
@property (nonatomic, weak, nullable) id<UCARPushEngineDelegate> delegate;

/**
 API域名，负责获取push server的ip和port
 */
@property (nonatomic, strong, nonnull) NSString *netManagerHost;

/**
 App版本号
 */
@property (nonatomic, strong, nonnull) NSString *appVersion;

/**
 业务名称
 @discussion http://wiki.10101111.com/pages/viewpage.action?pageId=15532553
 */
@property (nonatomic, strong, nonnull) NSString *sysName;

/**
 push_token
 @discussion http://wiki.10101111.com/pages/viewpage.action?pageId=96895124
 */
@property (nonatomic, strong, nonnull) NSString *deviceID;

/**
 重连次数
 */
@property (nonatomic, assign) NSInteger reconnectTimes;

/**
 开始服务
 */
- (void)startEngine;

/**
 停止服务
 */
- (void)stopEngine;

@end
