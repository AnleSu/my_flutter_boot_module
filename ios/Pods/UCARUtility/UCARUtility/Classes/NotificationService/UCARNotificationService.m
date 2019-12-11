//
//  UCARNotificationService.m
//  UCARUtility
//
//  Created  by hong.zhu on 2019/4/15.
//  
//

#import "UCARNotificationService.h"
#import <UserNotifications/UNUserNotificationCenter.h>
#import "UserNotifications/UNNotificationSettings.h"

@implementation UCARNotificationService

///获取系统通知权限是否开启
+ (void)getNotificationEnableWithCompletionHandler:(UCARBooleanBlock)completionHandler {
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            BOOL enable = settings.authorizationStatus != UNAuthorizationStatusNotDetermined && settings.authorizationStatus !=  UNAuthorizationStatusDenied;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) {
                    completionHandler(enable);
                }
            });
        }];
    } else if (@available(iOS 8.0, *)) {
        UIApplication * application = [UIApplication performSelector:@selector(sharedApplication)];
        BOOL enable = application.currentUserNotificationSettings.types != UIUserNotificationTypeNone;
        if (completionHandler) {
            completionHandler(enable);
        }
    } else {
        if (completionHandler) {
            completionHandler(NO);
        }
    }
}

///跳转到系统通知设置
+ (void)openSystemNotificationSettings {
    UIApplication * application = [UIApplication performSelector:@selector(sharedApplication)];
    if ([application respondsToSelector:@selector(openURL:)]) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [application performSelector:@selector(openURL:) withObject:url];
    }
}

@end
