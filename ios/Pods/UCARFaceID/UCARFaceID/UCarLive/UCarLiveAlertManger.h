//
//  UCarLiveAlertManger.h
//  Pods
//
//  Created by 宣佚 on 2017/6/26.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UCarLiveAlertManger : NSObject

// 成功提示
+ (void)showSuccess:(UIViewController *)vc;

// 错误提示
+ (void)showError:(UIViewController *)vc;

// 因为没有上传图像而产生的错误提示
+ (void)showErrorWithAvatarIsNil:(UIViewController *)vc;

+ (void)showCameraError:(UIViewController *)vc;

@end
