//
//  UCarLiveAlertManger.m
//  Pods
//
//  Created by 宣佚 on 2017/6/26.
//
//

#import "UCarLiveAlertManger.h"
#import "UCARLiveAlertView.h"

@implementation UCarLiveAlertManger

+ (void)showSuccess:(UIViewController *)vc {
    NSString *title = @"恭喜检测成功";
    NSString *msg = @"提示：感谢您为打造安全出行城市做出的贡献，请注意安全驾驶，祝您一路平安。";
    
    UCARLiveAlertView *alertView = [[UCARLiveAlertView alloc] initWithTitle:title message:msg containerView:vc.view btnBlock:^{
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertView show];
}

+ (void)showError:(UIViewController *)vc {
    NSString *title = @"检测失败";
    NSString *msg = @"提示：很遗憾没有通过安全检测，多次不通过将受到处罚。";
    
    UCARLiveAlertView *alertView = [[UCARLiveAlertView alloc] initWithTitle:title message:msg containerView:vc.view btnBlock:^{
         [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertView show];
}

+ (void)showCameraError:(UIViewController *)vc {
    NSString *title = @"打开前置摄像头失败";
    NSString *msg = @"";
    
    UCARLiveAlertView *alertView = [[UCARLiveAlertView alloc] initWithTitle:title message:msg containerView:vc.view btnBlock:^{
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertView show];
}

+ (void)showErrorWithAvatarIsNil:(UIViewController *)vc {
    NSString *title = @"检测失败";
    NSString *msg = @"提示：检测到您因没有上传头像导致检测失败，没有通过安全检测。请您尽快到分公司或所属企业进行处理，多次不通过将受到处罚。";
    
    UCARLiveAlertView *alertView = [[UCARLiveAlertView alloc] initWithTitle:title message:msg containerView:vc.view btnBlock:^{
         [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertView show];
}


@end
