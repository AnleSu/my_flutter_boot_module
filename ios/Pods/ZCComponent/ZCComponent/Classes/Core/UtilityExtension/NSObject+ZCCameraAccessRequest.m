//
//  NSObject+ZCCameraAccessRequest.m
//  Pods
//
//  Created by ZhangYuqing on 2019/5/30.
//

#import "NSObject+ZCCameraAccessRequest.h"
#import <AVFoundation/AVFoundation.h>

@implementation NSObject (ZCCameraAccessRequest)
+ (void)grantToCamera:(requestAccessSuccess)successBlock
{
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device)
    {
        // 判断授权状态
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted)
        {
            NSLog(@"因为系统原因, 无法访问相机");
            return;
        }
        else if (authStatus == AVAuthorizationStatusDenied)
        { // 用户拒绝当前应用访问相机
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请去-> [设置 - 隐私 - 相机 - 宝沃新零售商户端] 打开访问开关" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
            [alertView show];
            return;
        }
        else if (authStatus == AVAuthorizationStatusAuthorized)
        {
            // 用户允许当前应用访问相机
            if (successBlock) {
                successBlock();
            }
        }
        else if (authStatus == AVAuthorizationStatusNotDetermined)
        { // 用户还没有做出选择
            // 弹框请求用户授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    // 用户接受
                    if (successBlock) {
                        successBlock();
                    }
                }
            }];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"未检测到您的摄像头, 请在真机上测试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alertView show];
    }
}
@end
