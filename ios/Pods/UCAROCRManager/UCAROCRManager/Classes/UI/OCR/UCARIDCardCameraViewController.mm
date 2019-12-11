//
//  CameraViewController.m
//


#import "UCARIDCardCameraViewController.h"
#import <Masonry/Masonry.h>
#import "IDCardSlideLine.h"
#import <Photos/PHPhotoLibrary.h>

#import <UCARUIKit/UCARUIKit.h>
#import <Masonry/Masonry.h>
#import "OCRMacroUI.h"
#import "UIView+OCRToast.h"
#import "UCAROCRPlatformContext.h"
#import "OCRMacroColor.h"
#if TARGET_IPHONE_SIMULATOR//simulator
#elif TARGET_OS_IPHONE//device
#import "IDCardOCR.h"
#endif

#define kFocalScale 1.0

#define kDevcode @"56WE5BEE5LYY6L2"

#define kSafeTopHeight ((kScreenHeight>=812.0&& !IS_IPAD)? 44:0)
#define kSafeBottomHeight ((kScreenHeight>=812.0&& !IS_IPAD) ? 34:0)
#define kSafeLRX ((kScreenWidth>=812.0&&!IS_IPAD) ? 44:0)
#define kSafeBY ((kScreenWidth>=812.0&& !IS_IPAD) ? 21:0)
#define kSafeTopHasNavHeight ((kScreenHeight>=812.0&& !IS_IPAD)? 88:30)
#define kSafeTopNoNavHeight ((kScreenHeight>=812.0&& !IS_IPAD)? 44:0)

#define kResolutionWidth 1280.0
#define kResolutionHeight 720.0


@interface UCARIDCardCameraViewController () <
    UIAlertViewDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIGestureRecognizerDelegate
>
#if TARGET_IPHONE_SIMULATOR//simulator
#elif TARGET_OS_IPHONE//device
@property (strong, nonatomic) IDCardOCR *cardRecog;
#endif
@property (assign, nonatomic) BOOL isFoucePixel;
@property (assign, nonatomic) int sliderAllLine;
@property (assign, nonatomic) int confimCount;
@property (assign, nonatomic) int maxCount;
@property (assign, nonatomic) int pixelLensCount;
@property (assign, nonatomic) float isIOS8AndFoucePixelLensPosition;
@property (assign, nonatomic) float aLensPosition;
@property (assign, nonatomic) int recogReuslt;
@property (strong, nonatomic) UIButton *lightspotSwitch;
@property (assign, nonatomic) BOOL  lightspotOn;
@property (strong, nonatomic) UILabel *lightspotLabel;
@property (strong, nonatomic) UILabel *scanspotLabel;
@property (strong, nonatomic) NSString *originalImagepath;
@property (strong, nonatomic) NSString *cropImagepath;
@property (strong, nonatomic) NSString *headImagePath;


@property (nonatomic, strong, nullable) AVCaptureDevice *device;


@property (nonatomic, assign) BOOL adjustingFocus;


@property (nonatomic, weak, nullable) UIButton *photoButton;
@property (nonatomic, weak, nullable) UIButton *backButton;
@property (nonatomic, weak, nullable) UIButton *flashButton;


/**
 闪光灯是否开启
 */
@property (nonatomic, assign, getter=isFlashOn) BOOL flashOn;


@property (nonatomic, assign) BOOL handleSampleBuffer;


@property (nonatomic, weak, nullable) UIImageView *animationImageView;


@end


@implementation UCARVehicleLicense

@end


@implementation UCARIDCardCameraViewController


#pragma mark - Life Circle
/**
 创建默认的扫描界面
 */
+ (nonnull instancetype)defaultCameraViewController {
    UCARIDCardCameraViewController *cameraViewController = [[self alloc] init];
    // 6标识中国行驶证
    cameraViewController.mainID = 6;
    cameraViewController.typeName = @"China Vehicle License（机动车行驶证）";
    // 子分类为0
    cameraViewController.subID = 0;
    cameraViewController.cropType = 1;
    cameraViewController.recogOrientation = RecogInVerticalScreen;
    cameraViewController.handleSampleBuffer = YES;

    return cameraViewController;
}


- (void)dealloc {
#if TARGET_IPHONE_SIMULATOR//simulator
#elif TARGET_OS_IPHONE//device
    //free the recognition core
    [_cardRecog recogFree];
#endif
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    // 解决右滑返回失效问题
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    //set image path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    _originalImagepath = [documentsDirectory stringByAppendingPathComponent:@"originalImage.jpg"];
    _cropImagepath = [documentsDirectory stringByAppendingPathComponent:@"cropImage.jpg"];
    _headImagePath = [documentsDirectory stringByAppendingPathComponent:@"headImage.jpg"];
    _maxCount = 1;
#if TARGET_IPHONE_SIMULATOR//simulator
#elif TARGET_OS_IPHONE//device
    
    // Initialize the camera
    [self initialize];
    
    // Initialize the recognition core
    [self initRecog];
    
#endif

    [self addSubViews];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //隐藏navigationBar
    self.navigationController.navigationBarHidden = YES;
    // 是否允许右滑返回
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
    
    //reset
    _pixelLensCount = 0;
    _confimCount = 0;
    [self orientChange:nil];
    self.isProcessingImage = NO;
    
    //add NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    int flags = NSKeyValueObservingOptionNew;
    [camDevice addObserver:self
                forKeyPath:@"adjustingFocus"
                   options:flags
                   context:nil];
    if (_isFoucePixel) {
        [camDevice addObserver:self
                    forKeyPath:@"lensPosition"
                       options:flags
                       context:nil];
    }
    //start session
    [self.session startRunning];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // remove NSNotification
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarOrientationNotification
                                                  object:nil];
    AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [camDevice removeObserver:self
                   forKeyPath:@"adjustingFocus"];
    if (_isFoucePixel) {
        [camDevice removeObserver:self
                       forKeyPath:@"lensPosition"];
    }
    //stop session
    [self.session stopRunning];
    if (self.flashOn)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self flashButtonDidTouchUpInside:self.flashButton];
        });
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addScanAnimation];
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        self.adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
    }
    if ([keyPath isEqualToString:@"lensPosition"]) {
        _isIOS8AndFoucePixelLensPosition = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
    }
}


#if TARGET_IPHONE_SIMULATOR//simulator
#elif TARGET_OS_IPHONE//device


- (void)initRecog {
    NSDate *before = [NSDate date];
    self.cardRecog = [[IDCardOCR alloc] init];
    
    /*Acquire system language, load Chinese templates under Chinese system environment, and load English templates under non-Chinese system environment.
     Under English template, the field name is in English. For example, for Chinese field name “姓名”, the responsible English template is “Name”*/
//    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
//    int initLanguages;
//    NSString * preferredLang = [allLanguages objectAtIndex:0];
//    if ([preferredLang rangeOfString:@"zh"].length > 0) {
//        initLanguages = 0;
//    } else{
//        initLanguages = 3;
//    }
    
     int initLanguages = 0;
    
    /*Notice: This development code and the authorization under this project is just used for demo and please replace the  code and .lsc file under Copy Bundle Resources */
    int intRecog = [self.cardRecog InitIDCardWithDevcode:kDevcode recogLanguage:initLanguages];
    NSLog(@"intRecog = %d\ncoreVersion = %@",intRecog,[self.cardRecog getCoreVersion]);
    
    [self setRecongConfiguration];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:before];
    NSLog(@"time：%f", time);
}


- (void)setRecongConfiguration {
    //set recognition pattern
    if (self.mainID == 3000) { //Machine readable zone
        [self.cardRecog setIDCardIDWithMainID:1033
                                        subID:0
                                   subIDCount:1];
        [self.cardRecog addIDCardIDWithMainID:1034
                                        subID:0
                                   subIDCount:1];
        [self.cardRecog addIDCardIDWithMainID:1036
                                        subID:0
                                   subIDCount:1];
    } else if (self.mainID == 2) { //Chinese ID card
        [self.cardRecog setIDCardIDWithMainID:self.mainID
                                        subID:0
                                   subIDCount:1];
        [self.cardRecog addIDCardIDWithMainID:3
                                        subID:0
                                   subIDCount:1];
    } else {
        [self.cardRecog setIDCardIDWithMainID:self.mainID
                                        subID:self.subID
                                   subIDCount:1];
    }
    
    //set video stream crop type
    [self.cardRecog setVideoStreamCropTypeExWithType:self.cropType];
    
    //set picture clear value
    [self.cardRecog setPictureClearValueEx:80];
    
    if (self.mainID == 3000) {
        //Machine readable zone
        [_cardRecog setParameterWithMode:1
                                CardType:1033];
    } else {
        [_cardRecog setParameterWithMode:1
                                CardType:self.mainID];
    }
    //Set up document type for Chinese ID card (0-both sides; 1-obverse side; 2-reverse side)
    [self.cardRecog SetDetectIDCardType:0];
    
    //set rejection
    [self.cardRecog setIDCardRejectType:self.mainID
                                  isSet:true];
    
    //set roi
    CGFloat sTop = 0.0, sBottom = 0.0, sLeft = 0.0, sRight = 0.0;
    CGRect rect = [self setOverViewSmallRect];
    UIDeviceOrientation currentDeviceOrientatin = [self orientationFormInterfaceOrientation];
    NSDictionary *roiInfo = [self setRoiForDeviceOrientation:currentDeviceOrientatin roiRect:rect];
    sTop = [roiInfo[@"sTop"] floatValue];
    sBottom = [roiInfo[@"sBottom"] floatValue];
    sLeft = [roiInfo[@"sLeft"] floatValue];
    sRight = [roiInfo[@"sRight"] floatValue];
    [self.cardRecog setROIWithLeft:(int)sLeft
                               Top:(int)sTop
                             Right:(int)sRight
                            Bottom:(int)sBottom];
    
    //set recognition orientation
    if (self.recogOrientation == RecogInHorizontalScreen) {
        [self.cardRecog setRecogRotateType:0];
    } else {
        [self.cardRecog setRecogRotateType:1];
    }
}


#endif


// Initialize camera
- (void)initialize {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        // Judge camera authorization
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            UCARAlertView *alert = [[UCARAlertView alloc]initWithTitle:@"您没有开启相机权限，请前往设置中心打开相机权限。" buttonTitles:@[@"确定"] containerView:[UIApplication sharedApplication].keyWindow clickBlock:^(NSInteger index) {
                
            }];
            alert.isMessageMustCenter = YES;
            [alert show];
            return;
        }
    }
    
    //1. Create conversation layer
    self.session = [[AVCaptureSession alloc] init];
    // Set image quality, this resolution if the optimal for recognition, it is best not to change
    [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
    
    //2. Create, configure input device
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionBack) {
            self.device = device;
            self.captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                      error:nil];
        }
    }
    if ([self.session canAddInput:self.captureInput]) {
        [self.session addInput:self.captureInput];
    }
    
    //3.Create and configure preview output device
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self
                                     queue:queue];
    
    NSString *key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value
                                                              forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    [self.session addOutput:captureOutput];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        AVCaptureDeviceFormat *deviceFormat = self.device.activeFormat;
        if (deviceFormat.autoFocusSystem == AVCaptureAutoFocusSystemPhaseDetection) {
            _isFoucePixel = YES;
            _maxCount = 1;
        }
    }
    
    //4.Preview setting
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.preview setAffineTransform:CGAffineTransformMakeScale(kFocalScale, kFocalScale)];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.preview];
    
    for (AVCaptureConnection *connection in captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                self.videoConnection = connection;
                break;
            }
        }
        if (self.videoConnection) { break; }
    }
    //set  orientation
    UIDeviceOrientation currentDeviceOrientatin = [self orientationFormInterfaceOrientation];
    AVCaptureVideoOrientation currentVideoOrientation = [self avOrientationForDeviceOrientation:currentDeviceOrientatin];
    //NSLog(@"%ld  %ld",(long)deviceOrientation,(long)currentDeviceOrientatin);
    self.videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self.preview.connection.videoOrientation = currentVideoOrientation;
    //[self.videoConnection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
}


#if TARGET_IPHONE_SIMULATOR//simulator
#elif TARGET_OS_IPHONE//device


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    if (!self.handleSampleBuffer) {
        return;
    }
    
    if (self.isProcessingImage) {
        AudioServicesPlaySystemSound(1108);
        UIImage *tempImage = [self imageFromSampleBuffer:sampleBuffer];
        [self readyToGetImageEx:tempImage];
        return;
    }
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    int width = (int)CVPixelBufferGetWidth(imageBuffer);
    int height = (int)CVPixelBufferGetHeight(imageBuffer);
    
    BOOL isLoad = [self.cardRecog newLoadImageWithBuffer:baseAddress
                                                   Width:width
                                                  Height:height];
    //NSLog(@"isLoad = %d",isLoad);
    if (isLoad == 0) {
        //detect line
        IDCardSlideLine *sliderLine = [self.cardRecog newConfirmSlideLine];
        //NSLog(@"sliderLine.allLine == %d",sliderLine.allLine);
        BOOL lineState = (sliderLine.allLine > 0);
        _sliderAllLine = sliderLine.allLine;
        
        if (self.cropType == 1) {
            NSDictionary *conners = [self.cardRecog obtainRealTimeFourConersID];
            dispatch_sync(dispatch_get_main_queue(), ^ {
                [self showLightspotLabel];
                NSArray *points = [self getSmallRectConnersWithConners:conners];
                int isSucceed = [conners[@"isSucceed"] intValue];
                if (isSucceed == -1) {
                    CGRect rect = [self setOverViewSmallRect];
                    //NSArray *points1 = [self getFourPoints:rect];
//                    [_overView setFourePoints:points1];
                } else if (isSucceed == 1) {
//                    [_overView setFourePoints:points];
                }
//                [_overView setIsSucceed:isSucceed];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self showLightspotLabel];
            });
        }
        
        //detect light spot
        if (self.lightspotOn) {
            int spot = [self.cardRecog detectLightspot];
            if (spot == 0) {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    self.lightspotLabel.hidden = NO;
                });
                CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                return;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    self.lightspotLabel.hidden = YES;
                });
            }
        }
        if (lineState) {
            //For MRZ, after sideline detection, the return value of line detecting method stands for MRZ type, “1033”, “1034” and “1036” means the three type of MRZ
            _sliderAllLine = sliderLine.allLine;
            if (self.adjustingFocus) {
                CVPixelBufferUnlockBaseAddress(imageBuffer,0);
                return;
            }

            if (_aLensPosition == _isIOS8AndFoucePixelLensPosition) {
                _pixelLensCount++;
                if (_pixelLensCount == 1) {
                    _pixelLensCount--;
                    if (_confimCount == _maxCount) {
                        _confimCount = 0;
                        
                        //recognition
                         [self readyToRecog];
                    } else {
                        _confimCount++;
                    }
                }
            } else {
                _confimCount = 0;
                _pixelLensCount = 0;
                _aLensPosition = _isIOS8AndFoucePixelLensPosition;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                if (self.sliderAllLine != -139 && self.sliderAllLine != -202 && self.sliderAllLine != -145) {
                    self.scanspotLabel.hidden = YES;
                }
            });
        }
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
}


- (void)readyToGetImageEx:(UIImage *)image {
    //save original image
    [UIImageJPEGRepresentation(image, 1.0f) writeToFile:_originalImagepath
                                             atomically:YES];
    
    [self.cardRecog setIDCardRejectType:self.mainID
                                  isSet:true];
    
    //set Parameter and recog type
    [self.cardRecog setParameterWithMode:0
                                CardType:self.mainID];
    
    //set image preproccess
    [self.cardRecog processImageWithProcessType:7 setType:1];
    
    //load image
    int loadImage = [self.cardRecog LoadImageToMemoryWithFileName:_originalImagepath
                                                             Type:0];
    NSLog(@" = %d",loadImage);
    int recog = -1;
    if (self.mainID != 3000) {
        if (self.mainID == 2) {
            
            // determine the reverse and obverse sides of Chinese second-generation ID card
            recog = [self.cardRecog autoRecogChineseID];
            NSLog(@"sum = %d", recog);
        } else {
            // recognize documents without MRZ
            recog = [self.cardRecog recogIDCardWithMainID:self.mainID];
            NSLog(@"recog:%d",recog);
        }
    }
    if (recog == -6) {
        [self setRecongConfiguration];
        self.isProcessingImage = NO;
        return;
    }
    
    //stop session
    [_session stopRunning];
    //get recognition result
    dispatch_sync(dispatch_get_main_queue(), ^ {
        [self getRecogResult];
    });
    //reset the recognition core
    [self setRecongConfiguration];
    
    self.isProcessingImage = NO;
}


- (void)readyToRecog {
    _recogReuslt = -6;
    
    if (self.mainID == 3000) {
        // recognize MRZ
        _recogReuslt = [self.cardRecog recogIDCardWithMainID:_sliderAllLine subID:self.subID];//
        NSLog(@"recog:%d",_recogReuslt);
    } else if (self.mainID == 2) {
        // determine the reverse and obverse sides of Chinese second-generation ID card
        _recogReuslt = [self.cardRecog autoRecogChineseID];
        NSLog(@"sum = %d", _recogReuslt);
    } else {
        // recognize documents without MRZ
        _recogReuslt = [self.cardRecog recogIDCardWithMainID:self.mainID subID:self.subID];//[self.cardRecog recogIDCardWithMainID:self.mainID];
        NSLog(@"recog:%d",_recogReuslt);
    }
    
    
    if (_recogReuslt > 0) {
        //stop session
        [_session stopRunning];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        dispatch_sync(dispatch_get_main_queue(), ^ {
            [self getRecogResult];
        });
    }
}


//get result
- (void)getRecogResult {
    UCARVehicleLicense *vehicleLicense = nil;
    NSString *allResult = @"";
    //NSMutableDictionary *resultMuDic = [NSMutableDictionary dictionary];
    if (self.mainID != 3000) {
        // save the cut image to headImagePath
        int save = [self. cardRecog saveHeaderImage:_headImagePath];
        
        NSLog(@"save = %d", save);
        for (int i = 1; i < 30; i++) {
            // acquire fields value
            NSString *field = [self.cardRecog GetFieldNameWithIndex:i];
            // acquire fields result
            NSString *result = [self.cardRecog GetRecogResultWithIndex:i];
            //NSLog(@"%@:%@\n",field, result);
            if (field != nil && result != nil) {
                allResult = [allResult stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n", field, result]];
                //[resultMuDic setObject:result forKey:field];
                
                if ([field isEqualToString:@"号牌号码"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strCarNumber = result;
                } else if ([field isEqualToString:@"车辆类型"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strCarType = result;
                } else if ([field isEqualToString:@"所有人"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strOwnerName = result;
                } else if ([field isEqualToString:@"住址"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strAddress = result;
                } else if ([field isEqualToString:@"品牌型号"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strBrandModel = result;
                } else if ([field isEqualToString:@"车辆识别代号"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strCarCode = result;
                } else if ([field isEqualToString:@"发动机号码"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strEngineCode = result;
                } else if ([field isEqualToString:@"注册日期"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strRegisterDate = result;
                } else if ([field isEqualToString:@"发证日期"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strCertificateDate = result;
                } else if ([field isEqualToString:@"使用性质"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strUseNature = result;
                }
            }
        }
    } else {
        int mrzCount = _sliderAllLine == 1033 ?4:3;
        for (int i = 1; i < mrzCount; i++) {
            NSString *result = [self.cardRecog GetRecogResultWithIndex:i];
            if (result!= nil) {
                allResult = [allResult stringByAppendingString:[NSString stringWithFormat:@"%@\n", result]];
                
            } else {
                break;
            }
        }
        _sliderAllLine = 0;
    }
    
    // save the cut image to headImagePath
    int saveCrop = [self.cardRecog saveImage:_cropImagepath];
    NSLog(@"saveCrop = %d", saveCrop);
    
    //图像来源属性 0：原件;1：黑白复印件；2：彩色复印件；4：屏拍件
    int sourceType = [self.cardRecog GetImageSourceTypeWithCardType:self.mainID scale:1];
    NSString *sourceTypeStr = @"";
    switch (sourceType) {
        case 0: {
            sourceTypeStr = @"原件";
        } break;
        case 1: {
            sourceTypeStr = @"黑白复印件";
        } break;
        case 2: {
            sourceTypeStr = @"彩色复印件";
        } break;
        case 4: {
            sourceTypeStr = @"屏拍件";
        } break;
        default: {
        } break;
    }
    vehicleLicense.strImageSourceType = sourceTypeStr;
    allResult =  [allResult stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n",@"图像来源属性",sourceTypeStr]];
    if (self.mainID == 2011) {
        NSDictionary *posDic = [self.cardRecog getThaiFeaturePos];
        //NSLog(@"posDic = %@",posDic);
        for (int i=0; i<[[posDic allKeys] count]; i++) {
            NSArray *keys = [posDic allKeys];
            NSArray *values = [posDic allValues];
            allResult = [allResult stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n",keys[i],values[i]]];
        }
    }
    
    BOOL callDelegateMethods = (vehicleLicense
                                && self.delegate
                                && [self.delegate respondsToSelector:@selector(idCardCameraViewController:didDetectVehicleLicense:)]);
    if (callDelegateMethods) {
        UIImage *image = [UIImage imageWithContentsOfFile:_cropImagepath];
        vehicleLicense.scanImage = image;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate idCardCameraViewController:self
                              didDetectVehicleLicense:vehicleLicense];
        });
    }
}
#endif


//Get image from sampleBuffer
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationUp];
    CGImageRelease(quartzImage);
    
    //裁切预览时检边框区域图片
    CGRect tempRect = [self setOverViewSmallRect];
    CGFloat tWidth = (kFocalScale-1)*kScreenWidth*0.5;
    CGFloat tHeight = (kFocalScale-1)*kScreenHeight*0.5;
    //previewLayer上点坐标
    CGPoint pLTopPoint = CGPointMake((CGRectGetMinX(tempRect)+tWidth)/kFocalScale, (CGRectGetMinY(tempRect)+tHeight)/kFocalScale);
    CGPoint pRDownPoint = CGPointMake((CGRectGetMaxX(tempRect)+tWidth)/kFocalScale, (CGRectGetMaxY(tempRect)+tHeight)/kFocalScale);
    CGPoint pRTopPoint = CGPointMake((CGRectGetMaxX(tempRect)+tWidth)/kFocalScale, (CGRectGetMinY(tempRect)+tHeight)/kFocalScale);
    //CGPoint pLDownPoint = CGPointMake((CGRectGetMinX(tempRect)+tWidth)/kFocalScale, (CGRectGetMaxY(tempRect)+tHeight)/kFocalScale);
    
    //真实图片点坐标
    CGPoint iLTopPoint = [_preview captureDevicePointOfInterestForPoint:pRTopPoint];
    CGPoint iLDownPoint = [_preview captureDevicePointOfInterestForPoint:pLTopPoint];
    CGPoint iRTopPoint = [_preview captureDevicePointOfInterestForPoint:pRDownPoint];
    //CGPoint iRDownPoint = [_preview captureDevicePointOfInterestForPoint:pLDownPoint];
    
    CGFloat y = iLTopPoint.y*kResolutionHeight;
    CGFloat x = iLTopPoint.x*kResolutionWidth;
    CGFloat w = (iRTopPoint.x-iLTopPoint.x)*kResolutionWidth;
    CGFloat h = (iLDownPoint.y-iLTopPoint.y)*kResolutionHeight;
    CGRect rect = CGRectMake(x, y, w, h);
    
    CGImageRef imageRef = image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, rect);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context1 = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context1, rect, subImageRef);
    //UIImage *image1 = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    return (image);
}


/**
 添加子视图
 */
- (void)addSubViews
{
    // 对焦框
    CGRect focusRect = [self setOverViewSmallRect];
    UIView *focusView = [[UIView alloc] initWithFrame:self.view.bounds];
    focusView.backgroundColor = UIColor.blackColor;
    focusView.alpha = 0.40;
    [self.view addSubview:focusView];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [path appendPath:[[UIBezierPath bezierPathWithRect:focusRect] bezierPathByReversingPath]];
    shapeLayer.path = path.CGPath;
    focusView.layer.mask = shapeLayer;
    
    // 动画
    UIImage *animationImage = [UCAROCRPlatformContext imageNamed:@"ScanLineImage"];
    UIImageView *animationImageView = [[UIImageView alloc] initWithImage:animationImage];
    [self.view addSubview:animationImageView];
    [animationImageView mas_makeConstraints:^ (MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0.00);
        make.top.mas_equalTo(CGRectGetMinY(focusRect));
    }];
    self.animationImageView = animationImageView;
    
    // 返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UCAROCRPlatformContext imageNamed:@"ScanBackButtonIcon"]
                forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(backButtonDidTouchUpInside:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    self.backButton = backButton;
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"扫描行车证";
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont systemFontOfSize:18.00];
    [self.view addSubview:titleLabel];

    // 相册按钮
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton setTitle:@"相册"
               forState:UIControlStateNormal];
    [photoButton setTitleColor:UIColor.whiteColor
                    forState:UIControlStateNormal];
//    photoButton.titleLabel.font = [UIFont systemFontOfSize:12.00];
    [photoButton addTarget:self
                  action:@selector(photoButtonDidTouchUpInside:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoButton];
    self.photoButton = photoButton;
    
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(15*SCALE);
        } else {
            // Fallback on earlier versions
        }
    }];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLabel);
        make.left.mas_equalTo(20*SCALE);
        make.width.height.mas_equalTo(35*SCALE);
    }];

    [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(-20*SCALE);
        make.width.mas_equalTo(50*SCALE);
        make.height.mas_equalTo(44*SCALE);
    }];
    
    // 左上
    CGFloat leftTopImageViewLeading = CGRectGetMinX(focusRect);
    CGFloat leftTopImageViewTop = CGRectGetMinY(focusRect);
    UIImage *leftTopImage = [UCAROCRPlatformContext imageNamed:@"ScanLeftTop"];
    UIImageView *leftTopImageView = [[UIImageView alloc] initWithImage:leftTopImage];
    [self.view addSubview:leftTopImageView];
    [leftTopImageView mas_makeConstraints:^ (MASConstraintMaker *make) {
        make.leading.mas_equalTo(leftTopImageViewLeading);
        make.top.mas_equalTo(leftTopImageViewTop);
    }];
    
    // 右上
    CGFloat rightTopImageViewTrailing = CGRectGetWidth(self.view.bounds) - CGRectGetMaxX(focusRect);
    UIImage *rightTopImage = [UCAROCRPlatformContext imageNamed:@"ScanRightTop"];
    UIImageView *rightTopImageView = [[UIImageView alloc] initWithImage:rightTopImage];
    [self.view addSubview:rightTopImageView];
    [rightTopImageView mas_makeConstraints:^ (MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-rightTopImageViewTrailing);
        make.centerY.equalTo(leftTopImageView.mas_centerY);
    }];
    
    // 左下
    CGFloat leftBottomImageViewBottom = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(focusRect);
    UIImage *leftBottomImage = [UCAROCRPlatformContext imageNamed:@"ScanLeftBottom"];
    UIImageView *leftBottomImageView = [[UIImageView alloc] initWithImage:leftBottomImage];
    [self.view addSubview:leftBottomImageView];
    [leftBottomImageView mas_makeConstraints:^ (MASConstraintMaker *make) {
        make.centerX.equalTo(leftTopImageView.mas_centerX);
        make.bottom.mas_equalTo(-leftBottomImageViewBottom);
    }];
    
    // 右下
    UIImage *rightBottomImage = [UCAROCRPlatformContext imageNamed:@"ScanRightBottom"];
    UIImageView *rightBottomImageView = [[UIImageView alloc] initWithImage:rightBottomImage];
    [self.view addSubview:rightBottomImageView];
    [rightBottomImageView mas_makeConstraints:^ (MASConstraintMaker *make) {
        make.centerY.equalTo(leftBottomImageView.mas_centerY);
        make.trailing.equalTo(rightTopImageView.mas_trailing);
    }];
    
    // 提示
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    tipsLabel.text = @"请将条形码放入框内，即可自动扫描";
    tipsLabel.textColor = UIColor.whiteColor;
    [self.view addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^ (MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0.00);
        make.top.mas_equalTo(CGRectGetMaxY(focusRect) + 20.00);
    }];
    
    // 提示背景 View
    UIView *tipsBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    tipsBackgroundView.backgroundColor = UIColorFromRGB(0x464646);
    tipsBackgroundView.layer.masksToBounds = YES;
    tipsBackgroundView.layer.cornerRadius = 20.00;
    [self.view insertSubview:tipsBackgroundView
                belowSubview:tipsLabel];
    [tipsBackgroundView mas_makeConstraints:^ (MASConstraintMaker *make) {
        make.leading.equalTo(tipsLabel.mas_leading).offset(-13.00);
        make.trailing.equalTo(tipsLabel.mas_trailing).offset(12.00);
        make.top.equalTo(tipsLabel.mas_top).offset(-4.00);
        make.bottom.equalTo(tipsLabel.mas_bottom).offset(6.00);
    }];
    
    // 闪光灯按钮
    UIButton *flashButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [flashButton setImage:[UCAROCRPlatformContext imageNamed:@"ScanLightOff"]
              forState:UIControlStateNormal];
    [flashButton addTarget:self
                 action:@selector(flashButtonDidTouchUpInside:)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashButton];
    [flashButton mas_makeConstraints:^ (MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0.00);
        make.top.mas_equalTo(tipsBackgroundView.mas_bottom).offset(50.00);
    }];
    self.flashButton = flashButton;
    
    // 闪光灯提示
    UILabel *flashTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    flashTipsLabel.text = @"点击开启闪光灯";
    flashTipsLabel.font = [UIFont systemFontOfSize:12.00];
    flashTipsLabel.textColor = UIColor.whiteColor;
    [self.view addSubview:flashTipsLabel];
    [flashTipsLabel mas_makeConstraints:^ (MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0.00);
        make.top.equalTo(flashButton.mas_bottom).offset(10.00);
    }];
}


- (void)addScanAnimation
{
    [self.animationImageView.layer removeAllAnimations];
    
    CGRect focusRect = [self setOverViewSmallRect];
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:3.00
                          delay:0.00
                        options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear
                     animations:^ {
                         [weakSelf.animationImageView mas_updateConstraints:^ (MASConstraintMaker *make) {
                             make.top.mas_equalTo(CGRectGetMaxY(focusRect) - CGRectGetHeight(weakSelf.animationImageView.bounds));
                         }];
                         [weakSelf.animationImageView.superview setNeedsLayout];
                         [weakSelf.animationImageView.superview layoutIfNeeded];
                     } completion:^ (BOOL finished) {
                         [weakSelf.animationImageView mas_updateConstraints:^ (MASConstraintMaker *make) {
                             make.top.mas_equalTo(CGRectGetMinY(focusRect));
                         }];
                         [weakSelf.animationImageView.superview setNeedsLayout];
                         [weakSelf.animationImageView.superview layoutIfNeeded];
                     }];
}


- (CGPoint)realImageTranslateToScreenCoordinate:(CGPoint)point {
    CGFloat tWidth = (kFocalScale - 1) * kScreenWidth * 0.5;
    CGFloat tHeight = (kFocalScale - 1) * kScreenHeight * 0.5;
    CGPoint tempPoint = CGPointMake(point.x / kResolutionWidth, point.y / kResolutionHeight);
    CGPoint previewPoint = [self.preview pointForCaptureDevicePointOfInterest:tempPoint];
    previewPoint = CGPointMake((previewPoint.x - tWidth) * kFocalScale + tWidth, (previewPoint.y - tHeight) * kFocalScale + tHeight);
    
    return previewPoint;
}


- (NSArray *)getSmallRectConnersWithConners:(NSDictionary *)conners {
    CGPoint point1 = CGPointMake(0, 0);
    CGPoint point2 = CGPointMake(0, kScreenHeight);
    CGPoint point3 = CGPointMake(kScreenWidth, kScreenHeight);
    CGPoint point4 = CGPointMake(kScreenWidth, 0);
    
    int isS = [conners[@"isSucceed"] intValue];
    if (isS == 1) {
        point1 = [self realImageTranslateToScreenCoordinate:CGPointFromString([conners objectForKey:@"point1"])];
        point2 = [self realImageTranslateToScreenCoordinate: CGPointFromString([conners objectForKey:@"point2"])];
        point3 = [self realImageTranslateToScreenCoordinate: CGPointFromString([conners objectForKey:@"point3"])];
        point4 = [self realImageTranslateToScreenCoordinate: CGPointFromString([conners objectForKey:@"point4"])];
    }
    NSArray *points = @[ NSStringFromCGPoint(point1),
                         NSStringFromCGPoint(point2),
                         NSStringFromCGPoint(point3),
                         NSStringFromCGPoint(point4) ];
    
    return points;
}


#pragma mark - Button Actions
- (void)backButtonDidTouchUpInside:(nonnull id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)flashButtonDidTouchUpInside:(nonnull id)sender {
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    if (![device hasTorch]) {
        // no torch
        return;
    }
    
    [device lockForConfiguration:nil];
    if (!self.isFlashOn) {
        [device setTorchMode:AVCaptureTorchModeOn];
        self.flashOn = YES;
        [self.flashButton setImage:[UCAROCRPlatformContext imageNamed:@"ScanLightOn"]
                          forState:UIControlStateNormal];
    } else {
        [device setTorchMode: AVCaptureTorchModeOff];
        self.flashOn = NO;
        [self.flashButton setImage:[UCAROCRPlatformContext imageNamed:@"ScanLightOff"]
                          forState:UIControlStateNormal];
    }
    [device unlockForConfiguration];
}


- (void)photoButtonDidTouchUpInside:(nonnull id)sender {
    
    if (@available(iOS 11.0, *))
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusNotDetermined || status == PHAuthorizationStatusAuthorized) {
                [self showPhotoLibray];
            } else {
                [self showAlertView];
            }
        }];
    }
    else
    {
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (authStatus == PHAuthorizationStatusRestricted|| authStatus == PHAuthorizationStatusDenied) {
            [self showAlertView];
        } else {
            [self showPhotoLibray];
        }
    }
    

}


- (void)showPhotoLibray
{
    
    if (self.flashOn)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self flashButtonDidTouchUpInside:self.flashButton];
        });
    }

    self.isProcessingImage = YES;
    self.handleSampleBuffer = NO;
    
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    //    picker.allowsEditing=YES;
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:picker animated:YES completion:^{
            
        }];
    });
}

- (void)showAlertView
{
    UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    }];
    UIAlertAction *setUpAlert = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancelAlert];
    [alert addAction:setUpAlert];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)openLightspotSwich
{
    self.lightspotLabel.hidden = YES;
    self.lightspotSwitch.selected = !self.lightspotSwitch.selected;
    self.lightspotOn = self.lightspotSwitch.selected;
}


- (void)showLightspotLabel {
    if (self.sliderAllLine == -145) {
        self.scanspotLabel.text = NSLocalizedString(@"The document is too far away", nil);
        self.scanspotLabel.hidden = NO;
    } else if (_recogReuslt == -6 || self.sliderAllLine == -139) {
        self.scanspotLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Please recognize", nil), NSLocalizedString(self.typeName, nil)];
        self.scanspotLabel.hidden = NO;
    } else if (self.sliderAllLine == -202) {
    } else {
        self.scanspotLabel.hidden = YES;
    }
}


#pragma mark - NSNotification Actions
//reset video orientation
- (void)orientChange:(NSNotification *)notification {
    UIDeviceOrientation currentDeviceOrientatin = [self orientationFormInterfaceOrientation];
    AVCaptureVideoOrientation currentVideoOrientation = [self avOrientationForDeviceOrientation:currentDeviceOrientatin];
    
    [self.preview setAffineTransform:CGAffineTransformIdentity];
    self.preview.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.preview setAffineTransform:CGAffineTransformMakeScale(kFocalScale, kFocalScale)];
    self.preview.connection.videoOrientation = currentVideoOrientation;
    
    //set roi
    CGFloat sTop = 0.0, sBottom = 0.0, sLeft = 0.0, sRight = 0.0;
    CGRect rect = [self setOverViewSmallRect];
    NSDictionary *roiInfo = [self setRoiForDeviceOrientation:currentDeviceOrientatin
                                                     roiRect:rect];
    sTop = [roiInfo[@"sTop"] floatValue];
    sBottom = [roiInfo[@"sBottom"] floatValue];
    sLeft = [roiInfo[@"sLeft"] floatValue];
    sRight = [roiInfo[@"sRight"] floatValue];
#if TARGET_IPHONE_SIMULATOR//simulator
#elif TARGET_OS_IPHONE//device
    [_cardRecog setROIWithLeft:(int)sLeft Top:(int)sTop Right:(int)sRight Bottom:(int)sBottom];
    //NSLog(@"sTop=%f,sBottom=%f,sLeft=%f,sRight=%f",sTop,sBottom,sLeft,sRight);
    //NSLog(@"roi%d", a);
#endif
}


//get device orientation
- (UIDeviceOrientation)orientationFormInterfaceOrientation{
    UIDeviceOrientation tempDeviceOrientation = UIDeviceOrientationUnknown;
    UIInterfaceOrientation tempInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (tempInterfaceOrientation) {
        case UIInterfaceOrientationPortrait: {
            tempDeviceOrientation = UIDeviceOrientationPortrait;
            //NSLog(@"home down");
        } break;
        case UIInterfaceOrientationPortraitUpsideDown: {
            tempDeviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            //NSLog(@"home up");
        } break;
        case UIInterfaceOrientationLandscapeLeft: {
            tempDeviceOrientation = UIDeviceOrientationLandscapeRight;
            //NSLog(@"home left");
        } break;
        case UIInterfaceOrientationLandscapeRight: {
            tempDeviceOrientation = UIDeviceOrientationLandscapeLeft;
            //NSLog(@"home right");
        } break;
        default: {
        } break;
    }
    
    return tempDeviceOrientation;
}


//get video orientation
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation result = AVCaptureVideoOrientationLandscapeRight;
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeRight: {
            result = AVCaptureVideoOrientationLandscapeLeft;
        } break;
        case UIDeviceOrientationLandscapeLeft: {
            result = AVCaptureVideoOrientationLandscapeRight;
        } break;
        case UIDeviceOrientationPortrait: {
            result = AVCaptureVideoOrientationPortrait;
        } break;
        case UIDeviceOrientationPortraitUpsideDown: {
            result = AVCaptureVideoOrientationPortraitUpsideDown;
        } break;
        default: {
        } break;
    }
    
    return result;
}


//reset roi
- (NSMutableDictionary *)setRoiForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
                                            roiRect:(CGRect)rect {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    CGFloat tWidth = (kFocalScale - 1) * kScreenWidth * 0.5;
    CGFloat tHeight = (kFocalScale - 1) * kScreenHeight * 0.5;
    CGPoint pLTopPoint = CGPointMake((CGRectGetMinX(rect)+tWidth)/kFocalScale, (CGRectGetMinY(rect)+tHeight)/kFocalScale);
    CGPoint pLDownPoint = CGPointMake((CGRectGetMinX(rect)+tWidth)/kFocalScale, (CGRectGetMaxY(rect)+tHeight)/kFocalScale);
    CGPoint pRTopPoint = CGPointMake((CGRectGetMaxX(rect)+tWidth)/kFocalScale, (CGRectGetMinY(rect)+tHeight)/kFocalScale);
    CGPoint pRDownPoint = CGPointMake((CGRectGetMaxX(rect)+tWidth)/kFocalScale, (CGRectGetMaxY(rect)+tHeight)/kFocalScale);
    
    CGFloat sTop = 0.0, sBottom = 0.0, sLeft = 0.0, sRight = 0.0;
    CGPoint iLTopPoint,iLDownPoint,iRTopPoint,iRDownPoint;
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeRight: {
            iLTopPoint = [self.preview captureDevicePointOfInterestForPoint:pRDownPoint];
            iLDownPoint = [self.preview captureDevicePointOfInterestForPoint:pRTopPoint];
            iRTopPoint = [self.preview captureDevicePointOfInterestForPoint:pLDownPoint];
            iRDownPoint = [self.preview captureDevicePointOfInterestForPoint:pLTopPoint];
        } break;
        case UIDeviceOrientationLandscapeLeft: {
            iLTopPoint = [self.preview captureDevicePointOfInterestForPoint:pLTopPoint];
            iLDownPoint = [self.preview captureDevicePointOfInterestForPoint:pLDownPoint];
            iRTopPoint = [self.preview captureDevicePointOfInterestForPoint:pRTopPoint];
            iRDownPoint = [self.preview captureDevicePointOfInterestForPoint:pRDownPoint];
        } break;
        case UIDeviceOrientationPortrait: {
            iLTopPoint = [self.preview captureDevicePointOfInterestForPoint:pRTopPoint];
            iLDownPoint = [self.preview captureDevicePointOfInterestForPoint:pLTopPoint];
            iRTopPoint = [self.preview captureDevicePointOfInterestForPoint:pRDownPoint];
            iRDownPoint = [self.preview captureDevicePointOfInterestForPoint:pLDownPoint];
        } break;
        case UIDeviceOrientationPortraitUpsideDown: {
            iLTopPoint = [self.preview captureDevicePointOfInterestForPoint:pLDownPoint];
            iLDownPoint = [self.preview captureDevicePointOfInterestForPoint:pRDownPoint];
            iRTopPoint = [self.preview captureDevicePointOfInterestForPoint:pLTopPoint];
            iRDownPoint = [self.preview captureDevicePointOfInterestForPoint:pRTopPoint];
        } break;
        default: {
        } break;
    }
    if (self.recogOrientation == RecogInHorizontalScreen) {
        sTop = iLTopPoint.y*kResolutionHeight;
        sBottom = iLDownPoint.y*kResolutionHeight;
        sLeft = iLTopPoint.x*kResolutionWidth;
        sRight = iRTopPoint.x*kResolutionWidth;
    } else {
        sTop = iLTopPoint.x*kResolutionWidth;
        sBottom = iRTopPoint.x*kResolutionWidth;
        sLeft = (1-iLDownPoint.y)*kResolutionHeight;
        sRight = (1-iLTopPoint.y)*kResolutionHeight;
    }
    [result setObject:[NSNumber numberWithFloat:sTop] forKey:@"sTop"];
    [result setObject:[NSNumber numberWithFloat:sBottom] forKey:@"sBottom"];
    [result setObject:[NSNumber numberWithFloat:sLeft] forKey:@"sLeft"];
    [result setObject:[NSNumber numberWithFloat:sRight] forKey:@"sRight"];
    
    return result;
}


- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    
    return nil;
}


- (void)fouceMode {
    NSError *error;
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        if ([device lockForConfiguration:&error]) {
            CGPoint cameraPoint = [self.preview captureDevicePointOfInterestForPoint:self.view.center];
            [device setFocusPointOfInterest:cameraPoint];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            NSLog(@"Error: %@", error);
        }
    }
}


- (CGRect)setOverViewSmallRect {
    CGFloat width = 250.00;
    CGFloat height = width;
    CGFloat x = (CGRectGetWidth(self.view.bounds) - width) / 2.00;
    CGFloat y = (CGRectGetHeight(self.view.bounds) - height) / 2.00;
    
    return CGRectMake(x, y, width, height);
}


- (NSArray *)getFourPoints:(CGRect)sRect {
    CGPoint point1= CGPointMake(CGRectGetMinX(sRect), CGRectGetMinY(sRect));
    CGPoint point4= CGPointMake(CGRectGetMinX(sRect), CGRectGetMaxY(sRect));
    CGPoint point2= CGPointMake(CGRectGetMaxX(sRect), CGRectGetMinY(sRect));
    CGPoint point3= CGPointMake(CGRectGetMaxX(sRect), CGRectGetMaxY(sRect));
    NSArray *array = @[NSStringFromCGPoint(point1),NSStringFromCGPoint(point2),NSStringFromCGPoint(point3),NSStringFromCGPoint(point4)];
    
    return array;
}


#pragma mark - Override Methods
//隐藏状态栏
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}


#pragma mark - Private Methods
- (void)didFinishedSelect:(UIImage *)image {
    [UIImageJPEGRepresentation(image, 1.0f) writeToFile:_originalImagepath atomically:YES];
    NSLog(@"_originalImagepath= %@",_originalImagepath);
    [self performSelectorInBackground:@selector(recog) withObject:nil];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
    [self performSelectorInBackground:@selector(didFinishedSelect:)
                           withObject:image];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.handleSampleBuffer = YES;
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}


- (void)recog
{
#if TARGET_IPHONE_SIMULATOR//simulator
#elif TARGET_OS_IPHONE//device
    // Initialize the recognition core
    [self initRecog];
    
    //close rejection
    if (self.mainID == 2) {
        [self.cardRecog setIDCardRejectType:self.mainID
                                      isSet:true];
        [self.cardRecog setIDCardRejectType:3
                                      isSet:true];
    }
    
    //set parameter and card type
    [self.cardRecog setParameterWithMode:0
                                CardType:self.mainID];
    //image pretreatment
    [self.cardRecog processImageWithProcessType:7
                                        setType:1];
    
    
    //load image
    int loadImage = [self.cardRecog LoadImageToMemoryWithFileName:_originalImagepath
                                                             Type:0];
    NSLog(@"loadImage = %d", loadImage);
    if (self.mainID != 3000) {
        if (self.mainID == 2) {
            
            // determine the reverse and obverse sides of Chinese second-generation ID card
            int recog = [self.cardRecog autoRecogChineseID];
            NSLog(@"recog = %d",recog);
        } else {
            // recognize documents without MRZ
            int recog = [self.cardRecog recogIDCardWithMainID:self.mainID];
            NSLog(@"recog = %d",recog);
        }
        // save the cut image to headImagePath
        [self.cardRecog saveHeaderImage:_headImagePath];
        
        
        // save the cut full image to imagepath
        [self.cardRecog saveImage:_cropImagepath];
        UCARVehicleLicense *vehicleLicense = nil;
        NSString *allResult = @"";
        for (int i = 1; i < 25; i++) {
            // acquire fields value
            NSString *field = [self.cardRecog GetFieldNameWithIndex:i];
            // acquire fields result
            NSString *result = [self.cardRecog GetRecogResultWithIndex:i];
            NSLog(@"%@:%@\n", field, result);
            if (field != NULL) {
                if ([field isEqualToString:@"号牌号码"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strCarNumber = result;
                } else if ([field isEqualToString:@"车辆类型"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strCarType = result;
                } else if ([field isEqualToString:@"所有人"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strOwnerName = result;
                } else if ([field isEqualToString:@"住址"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strAddress = result;
                } else if ([field isEqualToString:@"品牌型号"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strBrandModel = result;
                } else if ([field isEqualToString:@"车辆识别代号"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strCarCode = result;
                } else if ([field isEqualToString:@"发动机号码"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strEngineCode = result;
                } else if ([field isEqualToString:@"注册日期"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strRegisterDate = result;
                } else if ([field isEqualToString:@"发证日期"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strCertificateDate = result;
                } else if ([field isEqualToString:@"使用性质"]) {
                    if (!vehicleLicense) {
                        vehicleLicense = [[UCARVehicleLicense alloc] init];
                    }
                    vehicleLicense.strUseNature = result;
                }
                allResult = [allResult stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n", field, result]];
            }
        }
        
        BOOL callDelegateMethods = (vehicleLicense
                                    && self.delegate
                                    && [self.delegate respondsToSelector:@selector(idCardCameraViewController:didDetectVehicleLicense:)]);
        if (callDelegateMethods) {
            UIImage *image = [UIImage imageWithContentsOfFile:_cropImagepath];
            vehicleLicense.scanImage = image;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate idCardCameraViewController:self
                                  didDetectVehicleLicense:vehicleLicense];
            });
        }
        else
        {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view ocr_makeToast:@"没有识别到证件"];
            });
        }
        
        if (![allResult isEqualToString:@""]) {
            // free initialize the recognition core
            [self.cardRecog recogFree];
        } else {
        }
    }
    #endif
    self.handleSampleBuffer = YES;
}


@end

