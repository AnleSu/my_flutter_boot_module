//
//  CameraViewController.h
//  BankCardRecog
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AudioToolbox/AudioToolbox.h>


typedef void(^resultBlockType)(NSString *result,UIImage *resultImage);

@interface UCARSmartOCRCameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong, nonatomic) AVCaptureSession *session;

@property (strong, nonatomic) AVCaptureDeviceInput *captureInput;

@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;

@property (strong, nonatomic) AVCaptureDevice *device;

@property (strong, nonatomic) AVCaptureConnection *videoConnection;

@property (strong, nonatomic) CAShapeLayer *maskWithHole;

@property (nonatomic, retain) CALayer *customLayer;

@property (assign,nonatomic) BOOL jumpToScanResultPage;
@property (copy, nonatomic) resultBlockType resultBlock;

/** 是否默认车牌号 */
@property (nonatomic, assign) BOOL isDefaultPlatScan;


/**
 默认是不隐藏底部之前的切换按钮 default = NO
 如果设置为YES，那么一些pop操作就要由自己来控制
 */
@property (nonatomic, assign) BOOL isHiddenToggleBtns;;

@end
