//
//  UCarLiveManager.h
//  UCarLive
//
//  Created by huyujin on 16/10/9.
//  Copyright © 2016年 UCarInc. All rights reserved.

/**
    NOTE::以下枚举类型参考FACE++ 
        具体可参考 LivenessEnumType.h
        部分状态内部暂未做处理：：
 */
 

#import <UIKit/UIKit.h>
#import "LivenessDetector.h"

@class UCarLiveManager;
@class UCarLiveModel;

typedef NS_ENUM(NSInteger, UCarLiveActionType) {
    UCARLIVE_ACTION_TYPE_NONE = 0,                ///< 初始状态
    UCARLIVE_ACTION_TYPE_BLINK = 1,               ///< 眨眼
    UCARLIVE_ACTION_TYPE_MOUTH = 2,               ///< 张嘴
    UCARLIVE_ACTION_TYPE_POSYAW = 3,              ///< 左右转头
    UCARLIVE_ACTION_TYPE_POSPITCH = 4,            ///< 上下点头
//    UCARLIVE_ACTION_TYPE_POSYAWLEFT = 5,          ///< 向左转头
//    UCARLIVE_ACTION_TYPE_POSYAWRIGHT = 6,         ///< 向右转头
//    UCARLIVE_ACTION_TYPE_POSPITCHUP = 7,          ///< 抬头
//    UCARLIVE_ACTION_TYPE_POSPITCHDOWN = 8,        ///< 低头
    UCARLIVE_ACTION_TYPE_DONE = 9,                ///< 结束状态
    UCARLIVE_ACTION_TYPE_AIMLESS = -1             ///< 持续监测
};

typedef NS_ENUM(NSInteger, UCarLiveFailedType) {
    UCARLIVE_FAILED_TYPE_ACTIONBLEND = 0,          ///< 动作错误
    UCARLIVE_FAILED_TYPE_NOTVIDEO,                 ///< 发现使用者在使用非连续的图像进行活体检测
    UCARLIVE_FAILED_TYPE_TIMEOUT,                  ///< 检测超时
    UCARLIVE_FAILED_TYPE_FACELOSTNOTCONTINUOUS,    ///< 人脸时不时丢失，被算法判定为非连续  (不适合提示用户)
    UCARLIVE_FAILED_TYPE_TOOMANYFACELOST,          ///< 人脸从拍摄区域消失时间过长 (不适合提示用户)
    UCARLIVE_FAILED_TYPE_FACENOTCONTINUOUS,        ///< 人脸动作过快导致非连续  (不适合提示用户)
    UCARLIVE_FAILED_TYPE_MASK,                     ///< 面具攻击  (不适合提示用户)
    
    UCARLIVE_FAILED_TYPE_CANCEL,                   ///< 人脸识别取消
    UCARLIVE_FAILED_TYPE_AUTHORIZATION_FAILED,      ///< SDK授权失败
    UCARLIVE_FAILED_TYPE_CAMERA_AUTHORIZATION_FAILED,      ///< 摄像头权限失败
    UCARLIVE_FAILED_TYPE_NO_AVATAR      ///< 没有头像
    
};

//////////////////////////////////////////////////////////////////////////////////////////////
// delegate

@protocol UCarLiveDelegate <NSObject>

@optional
- (void) uCarLiveManagerPresent:(UCarLiveManager *)uCarLiveManager ucarLiveVC:(UIViewController *)ucarLiveVC;
- (void) uCarLiveManager:(UCarLiveManager *)uCarLiveManager ucarLiveVC:(UIViewController *)ucarLiveVC successWithFaceData:(FaceIDData *)faceData;
- (void) uCarLiveManager:(UCarLiveManager *)uCarLiveManager ucarLiveVC:(UIViewController *)ucarLiveVC failWithErrorCode:(UCarLiveFailedType)errorCode;

@end


//////////////////////////////////////////////////////////////////////////////////////////////
// interface

@interface UCarLiveManager : NSObject

@property (nonatomic, strong) UIViewController *blockViewController;

- (instancetype) init;

/**
 *  活体检测入口 -- 只检测眨眼
 *
 *  @param parent       父视图 必填
 *  @param timeOut      动作超时时间，默认60s，如果设置为0，显示默认
 *
 */
- (void) presentControllerOlnyWinkWithParent:(UIViewController *)parent timeOut:(NSTimeInterval)timeOut;

- (void) presentControllerOlnyWinkWithParent:(UIViewController *)parent timeOut:(NSTimeInterval)timeOut avatarUrl:(NSString *)t_avatarUrl;

- (void) stopDetect;

- (void) restartDetect;

@property (nonatomic, weak) id<UCarLiveDelegate> ucarLiveDelegate;


#pragma mark - 人脸识别相关接口

/**
 *  人脸识别接口
 *
 *  @param face           人脸照片(图片或者url)（可传参数：uiimage or nsstring） 必填
 *  @param name           身份证姓名 必填
 *  @param idNumber       身份证号    必填
 *  @param success        回调成功 block
            UCarLiveModel：
 *  @param failure        回调失败 block
 */
- (void)verifyFace:(id)face
              name:(NSString *)name
          idNumber:(NSString *)idNumber
           success:(void (^)(UCarLiveModel *liveModel, UIViewController *ucarLiveVC))success
           failure:(void (^)(int code, NSString *msg, UIViewController *ucarLiveVC))failure;

/**
 *  身份证和人脸对比接口
 *
 *  @param idCardFace     身份证正面照片(图片或者url)（可传参数：uiimage or nsstring or nsdata） 必填
 *  @param liveFace       活体人脸照片(图片或者url)  （可传参数：uiimage or nsstring or nsdata） 必填
 *  @param picture_contrast_level       活体人脸照片,身份证正面图片对比强度 取值正整数 1：弱 2：较弱 3：较强 4：强
 *  @param success        回调成功 block
            UCarLiveModel：
 *  @param failure        回调失败 block
 */
- (void)verifyWithIDCardFace:(id)idCardFace
                    liveFace:(id)liveFace
      picture_contrast_level:(NSInteger)picture_contrast_level
                     success:(void (^)(int code, UCarLiveModel *liveModel, UIViewController *ucarLiveVC))success
                     failure:(void (^)(int code, NSString *msg, UIViewController *ucarLiveVC))failure;

@end
