//
//  UCarLiveCenter.m
//  UCarLive
//
//  Created by huyujin on 16/10/9.
//  Copyright © 2016年 UCarInc. All rights reserved.
//

#import "UCarLiveManager.h"
#import "MGBaseKit.h"
#import "MGLiveManager.h"

#import "UCarLiveModel.h"
#import "UCarLiveNetManager.h"
#import "NSData+UCARLiveBase64.h"

@interface UCarLiveManager ()

@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, strong) MGLiveManager *t_manager;


@end

@implementation UCarLiveManager

- (instancetype)init {
    
    self = [super init];
    if(self) {
        self.ucarLiveDelegate = nil;
        self.maxCount = 4;
    }
    return self;
}

- (void)presentControllerOlnyWinkWithParent:(UIViewController *)parent timeOut:(NSTimeInterval)timeOut {
    
    BOOL isRandom = NO;
    NSArray *actions = @[@(UCARLIVE_ACTION_TYPE_BLINK)];
    NSInteger count = 1;
    [self presentControllerWithParent:parent RandomAction:isRandom actions:actions count:count timeOut:timeOut];
}

- (void)presentControllerOlnyWinkWithParent:(UIViewController *)parent timeOut:(NSTimeInterval)timeOut avatarUrl:(NSString *)t_avatarUrl {
    
    if ([t_avatarUrl isEqualToString:@""] || t_avatarUrl == nil) {
        if(self.ucarLiveDelegate && [self.ucarLiveDelegate respondsToSelector:@selector(uCarLiveManager:ucarLiveVC:failWithErrorCode:)]) {
            [self.ucarLiveDelegate uCarLiveManager:self ucarLiveVC:parent failWithErrorCode:UCARLIVE_FAILED_TYPE_NO_AVATAR];
        }
        return;
    }
    
    [self presentControllerOlnyWinkWithParent:parent timeOut:timeOut];
}


- (void)presentControllerWithParent:(UIViewController *)parent
                        RandomAction:(BOOL)isRandom                     
                             actions:(NSArray<NSNumber *> *)actions
                               count:(NSInteger)count
                            timeOut:(NSTimeInterval)timeOut {
    
    
    BOOL isAuthorized = [MGLiveManager getLicense];
    if (!isAuthorized) { //若未获取授权，则联网授权
        [MGLicenseManager licenseForNetWokrFinish:^(bool License) {
            if (License) {
                MGLog(@"授权成功");
                [self handleFaceDetection:parent RandomAction:isRandom actions:actions count:count timeOut:timeOut];
            }else{
                MGLog(@"SDK授权失败，请检查");
                UCarLiveFailedType errorCode = UCARLIVE_FAILED_TYPE_AUTHORIZATION_FAILED;
                if(self.ucarLiveDelegate && [self.ucarLiveDelegate respondsToSelector:@selector(uCarLiveManager:ucarLiveVC:failWithErrorCode:)]) {
                    [self.ucarLiveDelegate uCarLiveManager:self ucarLiveVC:parent failWithErrorCode:errorCode];
                }
                return;
            }
        }];
    }else { //若已授权，则继续
        [self handleFaceDetection:parent RandomAction:isRandom actions:actions count:count timeOut:timeOut];
    }
}


- (void)handleFaceDetection:(UIViewController *)parent
                RandomAction:(BOOL)isRandom
                     actions:(NSArray<NSNumber *> *)actions
                       count:(NSInteger)count
                    timeOut:(NSTimeInterval)timeOut
{
    NSAssert(parent != nil, @"父视图不能为空...............");
    if(!isRandom) {
        NSAssert(actions != nil || actions.count > 0, @"非随机动作下，动作内容不能为空............");
        NSAssert(actions.count <= self.maxCount, @"最大动作个数不能超过：%@", [NSNumber numberWithInteger:self.maxCount]);
    }
    if(isRandom) {
        NSAssert(count <= self.maxCount, @"最大动作个数不能超过：%@", [NSNumber numberWithInteger:self.maxCount]);
    }
    
    MGLiveManager *manager = [[MGLiveManager alloc] init];
    manager.randomAction = isRandom;
    manager.actionCount = count;
    manager.actionArray = [actions mutableCopy];
    
    self.t_manager = manager;
    
    [self.t_manager startFaceDecetionViewController:parent
                                     timeOut:timeOut
                                   vcPresent:^(UIViewController *viewController) {
                                       self.blockViewController = viewController;
                                       if (self.ucarLiveDelegate && [self.ucarLiveDelegate respondsToSelector:@selector(uCarLiveManagerPresent:ucarLiveVC:)]) {
                                           [self.ucarLiveDelegate uCarLiveManagerPresent:self ucarLiveVC:viewController];
                                       }
                                   }
                                      finish:^(FaceIDData *faceData, UIViewController *viewController) {
                                          self.blockViewController = viewController;
                                          
        if (self.ucarLiveDelegate && [self.ucarLiveDelegate respondsToSelector:@selector(uCarLiveManager:ucarLiveVC:successWithFaceData:)]) {
            [self.ucarLiveDelegate uCarLiveManager:self ucarLiveVC:viewController successWithFaceData:faceData];
        }
    } error:^(MGLivenessDetectionFailedType errorType, UIViewController *viewController) {
        self.blockViewController = viewController;
        UCarLiveFailedType errorCode = UCARLIVE_FAILED_TYPE_ACTIONBLEND;
        if (errorType == DETECTION_FAILED_TYPE_CAMERA) {
            errorCode = UCARLIVE_FAILED_TYPE_CAMERA_AUTHORIZATION_FAILED;
        } else {
            errorCode = (UCarLiveFailedType)errorType;
        }
        if(self.ucarLiveDelegate && [self.ucarLiveDelegate respondsToSelector:@selector(uCarLiveManager:ucarLiveVC:failWithErrorCode:)]) {
            [self.ucarLiveDelegate uCarLiveManager:self ucarLiveVC:viewController failWithErrorCode:errorCode];
        }
    }];
    
    
}

- (void) stopDetect {
    if (self.t_manager != nil) {
        [self.t_manager stopDetect];
    }
}

- (void) restartDetect {
    if (self.t_manager != nil) {
        [self.t_manager restartDetect];
    }
}

#pragma mark - 接口

- (void)verifyFace:(id)face
              name:(NSString *)name
          idNumber:(NSString *)idNumber
           success:(void (^)(UCarLiveModel *liveModel, UIViewController *ucarLiveVC))success
           failure:(void (^)(int code, NSString *msg, UIViewController *ucarLiveVC))failure
{
    if (!face) {
        failure(999,@"提示：检测到您因没有上传头像导致检测失败，没有通过安全检测。请您尽快到分公司或所属企业进行处理，多次不通过将受到处罚。", self.blockViewController);
        return;
    }
    
    if (name.length<=0 || idNumber.length<=0) {
        NSAssert(false, @"参数缺失!");
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:name forKey:@"idcard_name"];
    [params setObject:idNumber forKey:@"idcard_number"];
    
    NSMutableDictionary *imageDict = [NSMutableDictionary dictionary];
    
    if ([face isKindOfClass:[UIImage class]]) {
        UIImage *faceImage = face;
        [imageDict setObject:faceImage forKey:@"image"];
    }else if ([face isKindOfClass:[NSString class]]) {
        NSString *faceImageUrlStr = face;
        [params setObject:faceImageUrlStr forKey:@"image_url"];
    }
    
    NSString *urlStr = @"verifyFace";
    [[UCarLiveNetManager sharedInstance] requestPostWithURL:urlStr params:params files:imageDict success:^(int code, NSDictionary *info) {
        UCarLiveModel *model = [[UCarLiveModel alloc] initWithDict:info];
        success(model, self.blockViewController);
    } failure:^(int code, NSString *msg) {
        failure(code,msg, self.blockViewController);
    }];
}

- (void)verifyWithIDCardFace:(id)idCardFace
                    liveFace:(id)liveFace
      picture_contrast_level:(NSInteger)picture_contrast_level
                     success:(void (^)(int code,UCarLiveModel *liveModel, UIViewController *ucarLiveVC))success
                     failure:(void (^)(int code, NSString *msg, UIViewController *ucarLiveVC))failure
{
    if (!idCardFace || !liveFace) {
        failure(999,@"提示：检测到您因没有上传头像导致检测失败，没有通过安全检测。请您尽快到分公司或所属企业进行处理，多次不通过将受到处罚。", self.blockViewController);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSMutableDictionary *imageDict = [NSMutableDictionary dictionary];
    
    if ([idCardFace isKindOfClass:[UIImage class]]) {
        UIImage *idCardFaceImage = idCardFace;
        [imageDict setObject:idCardFaceImage forKey:@"image1"];
    } else if ([idCardFace isKindOfClass:[NSString class]]) {
        NSString *idCardFaceImageUrlStr = idCardFace;
        [params setObject:idCardFaceImageUrlStr forKey:@"image1_url"];
    } else if ([idCardFace isKindOfClass:[NSData class]]) {
        NSString *idCarFaceImageBase64 = [idCardFace ucarlive_base64EncodedString];
        [params setObject:idCarFaceImageBase64 forKey:@"image1_base64"];
    }
    
    
    
    if ([liveFace isKindOfClass:[UIImage class]]) {
        UIImage *liveFaceImage = liveFace;
        [imageDict setObject:liveFaceImage forKey:@"image2"];
    } else if ([liveFace isKindOfClass:[NSString class]]) {
        NSString *liveFaceImageUrlStr = liveFace;
        [params setObject:liveFaceImageUrlStr forKey:@"image2_url"];
    } else if ([liveFace isKindOfClass:[NSData class]]) {
        NSString *idCarFaceImageBase64 = [liveFace ucarlive_base64EncodedString];
        [params setObject:idCarFaceImageBase64 forKey:@"image2_base64"];
    }
    
    [params setObject:@(picture_contrast_level) forKey:@"picture_contrast_level"];
    
    NSString *urlStr = @"verifyIDCardAndFace";
    [[UCarLiveNetManager sharedInstance] requestPostWithURL:urlStr params:params files:imageDict success:^(int code, NSDictionary *info) {
        UCarLiveModel *model = [[UCarLiveModel alloc] initWithDict:info];
        success(code,model, self.blockViewController);
    } failure:^(int code, NSString *msg) {
        failure(code,msg, self.blockViewController);
    }];
}


@end
