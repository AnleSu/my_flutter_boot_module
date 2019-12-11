//
//  UCARPushService.h
//  UCarDriver
//
//  Created by linux on 2016/9/23.
//  Copyright © 2016年 szzc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 收到socket push后的回调

 @param pushType 对应的push类型
 @param dict push内容
 @param UUID push packet id
 */
typedef void (^UCARPushReceiveHandler)(NSInteger pushType, NSDictionary *_Nonnull dict, NSString *_Nonnull UUID);

/**
 UCARPushService
 */
@interface UCARPushService : NSObject

/**
 服务是否在运行
 */
@property (nonatomic, assign, readonly) BOOL serviceRunning;

/**
 pushType是否为businessType，default = YES
 @discussion if NO，pushType将从UCARPushReceiveHandler的dict中解析，key值为pushType
 */
@property (nonatomic, assign) BOOL pushTypeIsBusinessType;

/**
 App版本号
 */
@property (nonatomic, copy, nonnull) NSString *appVersion;

/**
 业务名称
 @discussion http://wiki.10101111.com/pages/viewpage.action?pageId=15532553
 */
@property (nonatomic, copy, nonnull) NSString *sysName;

/**
 push实例

 @return a service instance
 */
+ (nonnull instancetype)sharedService;

/**
 开启push服务

 @param deviceID push_token
 @discussion http://wiki.10101111.com/pages/viewpage.action?pageId=96895124
 */
- (void)startServiceWithDeviceID:(nonnull NSString *)deviceID;

/**
 停止push服务
 */
- (void)stopService;

/**
 注册push类型

 @param object 注册对象，不持有
 @param pushType push类型
 @param handler 回调，持有
 @discussion 由于handler被持有，所以vc中如果用到了self，务必使用weakSelf
 @note 该方法非线程安全，务必在主线程调用
 */
- (void)registerPushService:(nonnull id)object
                forPushType:(NSInteger)pushType
            responseHandler:(nonnull UCARPushReceiveHandler)handler;

/**
 批量注册push类型

 @param object 注册对象，不持有
 @param pushTypes push类型
 @param handler 回调，持有
 @discussion 由于handler被持有，所以vc中如果用到了self，务必使用weakSelf
 @note 该方法非线程安全，务必在主线程调用
 */
- (void)registerPushService:(nonnull id)object
               forPushTypes:(nonnull NSArray<NSNumber *> *)pushTypes
            responseHandler:(nonnull UCARPushReceiveHandler)handler;

/**
 移除push注册

 @param object 注册对象
 @discussion 由于push的特殊性（一次性），不建议在viewDidDisappear中调用
 @note must unregister when dealloc
 */
- (void)unregisterPushService:(nonnull id)object;

/**
 移除push类型注册

 @param object 注册对象
 @param pushType push类型
 @discussion 由于push的特殊性（一次性），不建议在viewDidDisappear中调用
 @note must unregister when dealloc
 */
- (void)unregisterPushService:(nonnull id)object forPushType:(NSInteger)pushType;

@end
