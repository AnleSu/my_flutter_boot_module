//
//  UCARUIKitConfigInstance.m
//  UCARUIKit
//
//  Created by linux on 28/02/2018.
//

#import "UCARUIKitConfigInstance.h"

@implementation UCARUIKitConfigInstance

+ (instancetype)sharedConfig
{
    static UCARUIKitConfigInstance *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UCARUIKitConfigInstance alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _progressAlertButtonTitle = @"知道了";
        _toastViewConfig = [[UCARToastViewConfig alloc] init];
        _alertViewConfig = [[UCARAlertViewConfig alloc] init];
    }
    return self;
}

@end
