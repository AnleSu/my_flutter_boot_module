//
//  UCARProgressManager.m
//  UCar
//
//  Created by KouArlen on 16/3/18.
//  Copyright © 2016年 zuche. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "UCARProgressManager.h"
#import "UCARUIKitConfigInstance.h"
#import "UCARToastView.h"
#import "UCARAlertView.h"

static NSTimeInterval const UCARToastShowDurationDefault = 2.0;

@interface UCARProgressManager ()

@property (nonatomic, strong) UCARToastView *toastView;
@property (nonatomic, strong) NSTimer *toastTimer;

@property (nonatomic, strong) UCARAlertView *alertView;

@end

@implementation UCARProgressManager

+ (UCARProgressManager *)sharedManager {
    static dispatch_once_t once;
    static UCARProgressManager *sharedManager;
    dispatch_once(&once, ^ {
        sharedManager = [[UCARProgressManager alloc] init];
    });
    return sharedManager;
}

- (UCARToastView *)toastView
{
    if (!_toastView) {
        _toastView = [[UCARToastView alloc] initWithFrame:CGRectZero];
    }
    return _toastView;
}

//================Share Method========================

- (UIWindow *)frontWindow
{
    //注意：下面这段代码是从三方库SVProgressHUD中抄来的
    //https://github.com/SVProgressHUD/SVProgressHUD
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows){
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
        
        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            return window;
        }
    }
    return nil;
}

//================Message=================

+ (void)showMessage:(NSString*)message
{
    [[self sharedManager] showToastWithMessage:message iconType:UCARToastIconTypeNone duration:UCARToastShowDurationDefault];
}

+ (void)showInfoMessage:(NSString*)message
{
    [[self sharedManager] showToastWithMessage:message iconType:UCARToastIconTypeInfo duration:UCARToastShowDurationDefault];
}

+ (void)showSuccessMessage:(NSString*)message
{
    [[self sharedManager] showToastWithMessage:message iconType:UCARToastIconTypeSuccess duration:UCARToastShowDurationDefault];
}

+ (void)showErrorMessage:(NSString*)message
{
    [[self sharedManager] showToastWithMessage:message iconType:UCARToastIconTypeFail duration:UCARToastShowDurationDefault];
}

+ (void)showMessage:(NSString*)message duration:(NSTimeInterval)duration
{
    [[self sharedManager] showToastWithMessage:message iconType:UCARToastIconTypeNone duration:duration];
}

+ (void)showInfoMessage:(NSString*)message duration:(NSTimeInterval)duration
{
    [[self sharedManager] showToastWithMessage:message iconType:UCARToastIconTypeInfo duration:duration];
}

+ (void)showSuccessMessage:(NSString*)message duration:(NSTimeInterval)duration
{
    [[self sharedManager] showToastWithMessage:message iconType:UCARToastIconTypeSuccess duration:duration];
}

+ (void)showErrorMessage:(NSString*)message duration:(NSTimeInterval)duration
{
    [[self sharedManager] showToastWithMessage:message iconType:UCARToastIconTypeFail duration:duration];
}

- (void)showToastWithMessage:(NSString *)message iconType:(UCARToastIconType)iconType duration:(NSTimeInterval)duration
{
    if (message.length == 0) {
        return;
    }
    [_toastTimer invalidate];
    [self dismissToast];
    
    UIWindow *window = [self frontWindow];
    if (window) {
        [window addSubview:self.toastView];
        
        [self.toastView setText:message iconType:iconType];
        
        _toastTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(dismissToast) userInfo:nil repeats:NO];
    }
}

- (void)dismissToast
{
    if (self.toastView.superview) {
        [self.toastView removeFromSuperview];
    }
}

//==============Alert===================
+ (void)showMessageUseAlert:(NSString *)message
{
    [[self sharedManager] showMessageUseAlert:message];
}

- (void)showMessageUseAlert:(NSString *)message
{
    if (message.length == 0) {
        return;
    }
    [self dissmissAlert];
    
    UIWindow *window = [self frontWindow];
    if (window) {
        _alertView = [[UCARAlertView alloc] initWithTitle:message buttonTitles:@[[UCARUIKitConfigInstance sharedConfig].progressAlertButtonTitle] containerView:window clickBlock:^(NSInteger index) {
        }];
        [_alertView show];
    }
}

- (void)dissmissAlert
{
    if (_alertView.superview) {
        [_alertView hide];
    }
}

@end
