//
//  UCarFRService.m
//  MGBaseKit
//
//  Created by huyujin on 16/10/12.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "UCarFRService.h"
#import "MGLicenseManager.h"


#define UCarSDKVersion @"1.0"

@interface UCarFRService ()

@property (nonatomic, readwrite, copy) NSString *appId;
@property (nonatomic, readwrite, copy) NSString *appToken;

@property (nonatomic, readwrite, copy) NSString *sdkVersion;

@end

@implementation UCarFRService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.debugMode = NO;
    }
    return self;
}

+ (instancetype)sharedInstance {
    
    static dispatch_once_t once = 0;
    static UCarFRService *ucarFRService;
    dispatch_once(&once, ^{
        ucarFRService = [[self alloc] init];
    });
    return ucarFRService;
}

- (void)startWithAppId:(NSString *)appId appToken:(NSString *)appToken{
    self.appId = appId;
    self.appToken = appToken;
    
    [MGLicenseManager licenseForNetWokrFinish:^(bool license) {
        NSString *msg = license ? @"人脸识别UCarFR SDK 授权【成功】":@"人脸识别UCarFR SDK 授权【失败】";
        NSLog(@"%@",msg);
    }];
}

#pragma mark -

+ (NSString *)sdkVersion {
    return UCarSDKVersion;
}


@end
