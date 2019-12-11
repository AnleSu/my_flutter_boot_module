//
//  UCARCIDBundleManager.m
//  UCARCertifyID
//
//  Created by 宣佚 on 2018/1/9.
//

#import "UCARCIDBundleManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation UCARCIDBundleManager


+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static UCARCIDBundleManager *instance = nil;
    dispatch_once( &onceToken, ^{
        instance = [[UCARCIDBundleManager alloc] init];
    });
    return instance;
}

- (UIImage *)imageName:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [[bundle resourcePath] stringByAppendingPathComponent:@"UCARCertifyID.bundle"];
    bundle = [NSBundle bundleWithPath:bundlePath];
    
    UIImage *img;
    if (name && bundle) {
        img = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    }
    return img;
}

- (void)getCameraAuth:(void(^)(BOOL ispass))block {
    AVAuthorizationStatus AVstatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];//相机权限
    if (AVstatus == AVAuthorizationStatusDenied || AVstatus == AVAuthorizationStatusRestricted) {
        block(NO);
    }
    else if (AVstatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            block(granted);
        }];
    }
    else {
        block(YES);
    }
}

@end
