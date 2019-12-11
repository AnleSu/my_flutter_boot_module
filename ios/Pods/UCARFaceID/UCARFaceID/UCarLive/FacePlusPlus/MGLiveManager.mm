//
//  MGFaceManager.m
//  MGFaceDetection
//
//  Created by 张英堂 on 15/12/22.
//  Copyright © 2015年 megvii. All rights reserved.
//

#import "MGLiveManager.h"
#import "MGLiveDetectViewController.h"
#import "MGLiveActionManager.h"
#import "MGLiveDetectionManager.h"
#import "MGLiveDefaultDetectVC.h"

@interface MGLiveManager ()

@property (nonatomic, strong) MGLiveDefaultDetectVC *first;

@end

@implementation MGLiveManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.actionCount = 3;
        self.actionTimeOut = 60.0f;
        self.detectionWithMovier = NO;
        self.detectionWithSound = NO;

        self.randomAction = YES;
        self.hideNavigationBar = YES;
        
        self.detectionType = MGLiveDetectionTypeAll;
    }
    return self;
}

-(void)startFaceDecetionViewController:(UIViewController *)viewController
                               timeOut:(NSTimeInterval)timeOut
                             vcPresent:(void(^)(UIViewController *viewController))vcPresent
                                finish:(void(^)(FaceIDData *faceData, UIViewController *viewController))finish
                                 error:(void(^)(MGLivenessDetectionFailedType errorType, UIViewController *vc))error {
    
    if (NO == [self checkSetting]) {
        if (error) {
            error(DETECTION_FAILED_TYPE_NOTVIDEO, nil);
        }
        return;
    }
    
    MGVideoManager *videoManager = [MGVideoManager videoPreset:AVCaptureSessionPreset640x480
                                                devicePosition:AVCaptureDevicePositionFront
                                                   videoRecord:self.detectionWithMovier
                                                    videoSound:self.detectionWithSound];
    
    MGLiveActionManager *ActionManager = [MGLiveActionManager LiveActionRandom:self.randomAction
                                                                   actionArray:self.actionArray
                                                                   actionCount:self.actionCount];
    
    MGLiveErrorManager *errorManager = [[MGLiveErrorManager alloc] initWithFaceCenter:CGPointMake(0.5, 0.5)];

    MGLiveDetectionManager *liveManager = [[MGLiveDetectionManager alloc] initWithActionTime:self.actionTimeOut
                                                                               actionManager:ActionManager
                                                                                errorManager:errorManager];
    [liveManager setDetectionType:self.detectionType];
    
    self.first = [[MGLiveDefaultDetectVC alloc] initWithNibName:nil bundle:nil];
    [self.first setLiveManager:liveManager];
    [self.first setVideoManager:videoManager];
    [self.first setTimeOutSecond:timeOut];
    [self.first setQualityfinish:self.Qualityfinish];
    
    [self.first setDetectFinish:finish];
    [self.first setDetectError:error];
    [self.first setDetectPresent:vcPresent];
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:self.first];
    [navi.navigationBar setHidden:self.hideNavigationBar];
    [viewController presentViewController:navi animated:YES completion:nil];
    
    if (self.first.detectPresent) {
        self.first.detectPresent(navi);
    }
}

- (void)stopDetect {
    [self.first stopDetect];
}

- (void) restartDetect {
    [self.first restartDetect];
}

/* 简单的配置检测 */
- (BOOL)checkSetting{
    
    if (self.actionCount > 4) {
        return NO;
    }
    if (self.actionArray.count > 4) {
        return NO;
    }
    if (TARGET_IPHONE_SIMULATOR) {
        return NO;
    }
    
    return YES;
}


+ (NSString *)LiveDetectionVersion{
    return [MGLivenessDetector getVersion];
}

+ (BOOL)getLicense{
    NSString *sdkVersion = [MGLiveManager LiveDetectionVersion];
    MGLog(@"version : %@", sdkVersion);
    
    NSArray *sdkInfo = [sdkVersion componentsSeparatedByString:@","];
    if (sdkInfo.count > 1) {
        return YES;
    }
    
    NSDate *nowDate = [NSDate date];
    NSDictionary *licenseDic = [MGLivenessDetector checkCachedLicense];
    NSDate *sdkDate = [licenseDic valueForKey:[self LiveDetectionVersion]];
    
    MGLog(@"faceSDK licenes:%@ -- %@", sdkDate, nowDate);
    
    if ([sdkDate compare:nowDate] == NSOrderedDescending) {
        return YES;
    }
    
    return NO;
}

+ (NSDate *)getLicenseDate{
    NSDictionary *licenseDic = [MGLivenessDetector checkCachedLicense];
    
    NSDate *sdkDate = [licenseDic valueForKey:[self LiveDetectionVersion]];
    return sdkDate;
}



@end
