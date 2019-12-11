//
//  UCARNotificationService.h
//  UCARUtility
//
//  Created  by hong.zhu on 2019/4/15.
//  
//

#import <Foundation/Foundation.h>

/// 系统通知权限判断回调
typedef void(^UCARBooleanBlock)(BOOL enable);

NS_ASSUME_NONNULL_BEGIN

/**
 系统推送开关检测与打开
 */
@interface UCARNotificationService : NSObject

/**
 获取系统通知权限是否开启
 */
+ (void)getNotificationEnableWithCompletionHandler:(UCARBooleanBlock)completionHandler;

/**
 跳转到系统通知设置
 */
+ (void)openSystemNotificationSettings;

@end

NS_ASSUME_NONNULL_END
