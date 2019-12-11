//
//  CameraViewController.h
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RecogOrientation){
    RecogInHorizontalScreen  = 0,
    RecogInVerticalScreen    = 1,
};


@class UCARIDCardCameraViewController, UCARVehicleLicense;


@protocol IDCardCameraViewControllerDelegate <NSObject>
@optional
- (void)idCardCameraViewController:(nonnull UCARIDCardCameraViewController *)idCardCameraViewController
           didDetectVehicleLicense:(nonnull UCARVehicleLicense *)vehicleLicense; 

@end


@interface UCARIDCardCameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, retain) CALayer *customLayer;

@property (nonatomic, assign) BOOL isProcessingImage;

@property (strong, nonatomic) AVCaptureSession *session;

@property (strong, nonatomic) AVCaptureDeviceInput *captureInput;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;

@property (strong, nonatomic) AVCaptureConnection *videoConnection;

@property (assign, nonatomic) RecogOrientation recogOrientation;

@property (assign, nonatomic) int mainID;
@property (assign, nonatomic) int subID;

@property (copy, nonatomic) NSString *typeName;

//“0”- guide frame; “1”- automatic line detection
@property (assign, nonatomic) int cropType;


@property (nonatomic, weak, nullable) id<IDCardCameraViewControllerDelegate> delegate;


/**
 创建默认的扫描界面
 */
+ (nonnull instancetype)defaultCameraViewController;


@end


/**
 行车证
 */
@interface UCARVehicleLicense: NSObject


/**
 号牌号码
 */
@property (nonatomic, copy, nullable) NSString *strCarNumber;


/**
 车辆类型
 */
@property (nonatomic, copy, nullable) NSString *strCarType;


/**
 所有人
 */
@property (nonatomic, copy, nullable) NSString *strOwnerName;


/**
 住址
 */
@property (nonatomic, copy, nullable) NSString *strAddress;


/**
 品牌型号
 */
@property (nonatomic, copy, nullable) NSString *strBrandModel;


/**
 车辆识别代号
 */
@property (nonatomic, copy, nullable) NSString *strCarCode;


/**
 发动机号码
 */
@property (nonatomic, copy, nullable) NSString *strEngineCode;


/**
 注册日期
 */
@property (nonatomic, copy, nullable) NSString *strRegisterDate;


/**
 发证日期
 */
@property (nonatomic, copy, nullable) NSString *strCertificateDate;



/**
 使用性质
 */
@property (nonatomic, copy, nullable) NSString *strUseNature;


/**
 图像来源
 */
@property (nonatomic, copy, nullable) NSString *strImageSourceType;


/**
 扫描到的行驶证图片
 */
@property (nonatomic, strong, nullable) UIImage *scanImage;



@end

NS_ASSUME_NONNULL_END
