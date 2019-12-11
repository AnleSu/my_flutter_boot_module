//
//  CameraViewController.m
//

#import "UCARSmartOCRCameraViewController.h"
#import "UCARSmartOCROverView.h"
#import <Photos/PHPhotoLibrary.h>

#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
#import "SmartOCR.h"
#import "PlateIDOCR.h"

#endif

#import "PlateResult.h"
#import "PlateFormat.h"
#import "UIImage+OCRFixOrientation.h"

#import <UCARUIKit/UCARUIKit.h>
#import <Masonry/Masonry.h>
#import "OCRMacroUI.h"
#import "UIView+OCRToast.h"
#import "UCAROCRPlatformContext.h"

//焦距倍数
#define kFocalScale 1.5

//分辨率 与相机分辨率对应：AVCaptureSessionPreset1920x1080
#define kResolutionWidth 1920.0
#define kResolutionHeight 1080.0
//cellName
#define kListCellName @"listcell"

//开发码：开发码和授权文件(smartvisitionocr.lsc)一一对应，替换授权文件需要修改开发码
#define kDevcode @"56WE5BEE5LYY6L2"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define kSafeTopHeight ((kScreenHeight==812.0&&kScreenWidth==375.0)? 44:0)

//不隐藏导航栏
#define kSafeTopHasNavHeight ((kScreenHeight==812.0&&kScreenWidth==375.0)? 88:30)
//隐藏掉导航栏
#define kSafeTopNoNavHeight ((kScreenHeight==812.0&&kScreenWidth==375.0)? 44:0)
#define kSafeBottomHeight ((kScreenHeight==812.0&&kScreenWidth==375.0) ? 34:0)
#define kSafeLRX ((kScreenWidth==812.0&&kScreenHeight==375.0) ? 44:0)
#define kSafeBY ((kScreenWidth==812.0&&kScreenHeight==375.0) ? 21:0)

static NSString * plateTitle = @"扫描车牌号";
static NSString * vinTitle = @"扫描车架号";
static NSString * plateTips = @"请将车牌号放入框内，即可自动扫描";
static NSString * vinTips = @"请将车架号放入框内，即可自动扫描";
static NSString * flashOpenTips = @"点击开启闪光灯";
static NSString * flashCloseTips = @"点击关闭闪光灯";


@interface UCARSmartOCRCameraViewController ()<UIAlertViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>{

#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
    UCARSmartOCROverView *_overView;//预览界面覆盖层,显示是否找到边
    SmartOCR *_ocr;//核心
    PlateIDOCR *_plateIDRecog;
#endif
    BOOL _isTakePicBtnClick;//是否点击拍照按钮
    BOOL _on;//闪光灯是否打开
    float _isIOS8AndFoucePixelLensPosition;//相位聚焦下镜头位置
    BOOL _isFoucePixel;//是否开启对焦
    BOOL _isChangedType;//切换识别类型
    NSTimer *_timer;//定时器
    
}
@property (strong,nonatomic) UIButton *takePicBtn;//拍照按钮
@property (assign, nonatomic) BOOL adjustingFocus;//是否正在对焦
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *backBtn;
@property (strong, nonatomic) UIButton *imgChooseBtn;
@property (strong, nonatomic) UILabel *tipsLabel;
@property (strong, nonatomic) UIButton *flashBtn;
@property (strong, nonatomic) UILabel *flashTips;
@property (strong, nonatomic) UIButton *plateShiftBtn;
@property (strong, nonatomic) UIButton *vinShiftBtn;
@property (assign, nonatomic) BOOL isPlateReco;
@property (strong, nonatomic) NSString *imageType;
@end

@implementation UCARSmartOCRCameraViewController

#pragma mark - getter & setter

-(UILabel *)titleLabel
{
    if(!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = vinTitle;
        _titleLabel.font = [UIFont systemFontOfSize:18*SCALE];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

-(UIButton *)backBtn
{
    if(!_backBtn)
    {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UCAROCRPlatformContext imageNamed:@"ScanBackButtonIcon"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(UIButton *)imgChooseBtn
{
    if(!_imgChooseBtn)
    {
        _imgChooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_imgChooseBtn setTitle:@"相册" forState:UIControlStateNormal];
        _imgChooseBtn.titleLabel.font = [UIFont systemFontOfSize:14*SCALE];
        [_imgChooseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_imgChooseBtn addTarget:self action:@selector(openImageChoose) forControlEvents:UIControlEventTouchUpInside];
    }
    return _imgChooseBtn;
}


-(UILabel *)tipsLabel
{
    if(!_tipsLabel)
    {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.backgroundColor = [UIColor clearColor];
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.text = vinTips;
        _tipsLabel.font = [UIFont systemFontOfSize:14*SCALE];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipsLabel;
}

-(UIButton *)plateShiftBtn
{
    if(!_plateShiftBtn)
    {
        _plateShiftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_plateShiftBtn setTitle:@"车牌号" forState:UIControlStateNormal];
        _plateShiftBtn.titleLabel.font = [UIFont systemFontOfSize:14*SCALE];
        [_plateShiftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_plateShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"plateIcon"] forState:UIControlStateNormal];
        [_plateShiftBtn addTarget:self action:@selector(shiftPlateReco) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plateShiftBtn;
}

-(UIButton *)vinShiftBtn
{
    if(!_vinShiftBtn)
    {
        _vinShiftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_vinShiftBtn setTitle:@"车架号" forState:UIControlStateNormal];
        _vinShiftBtn.titleLabel.font = [UIFont systemFontOfSize:14*SCALE];
        [_vinShiftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_vinShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"vinIcon-pre"] forState:UIControlStateNormal];
        [_vinShiftBtn addTarget:self action:@selector(shiftVinReco) forControlEvents:UIControlEventTouchUpInside];

    }
    return _vinShiftBtn;
}

-(UIButton *)flashBtn
{
    if(!_flashBtn)
    {
        _flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashBtn setTitle:flashOpenTips forState:UIControlStateNormal];
        _flashBtn.titleLabel.font = [UIFont systemFontOfSize:14*SCALE];
        [_flashBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_flashBtn setImage:[UCAROCRPlatformContext imageNamed:@"ScanLightOff"] forState:UIControlStateNormal];
        [_flashBtn addTarget:self action:@selector(flashBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _flashBtn;
}

-(UILabel *)flashTips
{
    if(!_flashTips)
    {
        _flashTips = [[UILabel alloc] init];
        _flashTips.backgroundColor = [UIColor clearColor];
        _flashTips.textColor = [UIColor whiteColor];
        _flashTips.text = flashOpenTips;
        _flashTips.font = [UIFont systemFontOfSize:14*SCALE];
        _flashTips.textAlignment = NSTextAlignmentCenter;
    }
    return _flashTips;
}

- (void)setIsDefaultPlatScan:(BOOL)isPlatScan
{
    _isDefaultPlatScan = isPlatScan;
    _isPlateReco = isPlatScan;
}

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // 解决右滑返回失效问题
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
    self.view.backgroundColor = [UIColor clearColor];
    
    //初始化相机
    [self initialize];
    
    //初始化识别核心
    [self initOCRSource];
    [self initRecog];
    
#endif
    //创建相机界面控件
    [self createCameraView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToSelfShouldToRestoreScan) name:@"ZCScanViewControllerPopToSelfShouldToRestoreScan" object:nil];
}


- (void)dealloc{
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机

    int uninit = [_ocr uinitOCREngine];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"uninit=======%d", uninit);
#endif

}

- (void)popToSelfShouldToRestoreScan
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.session startRunning];
    });
}


- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏navigationBar
    self.navigationController.navigationBarHidden = YES;
    // 是否允许右滑返回
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
    
    AVCaptureDevice*camDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    int flags = NSKeyValueObservingOptionNew;
    //注册通知
    [camDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
    if (_isFoucePixel) {
        [camDevice addObserver:self forKeyPath:@"lensPosition" options:flags context:nil];
    }
    
    //定时器 开启连续曝光
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setExposureModeContinuousAutoExposureEx) userInfo:nil repeats:YES];
    self.view.userInteractionEnabled = YES;
    _on = NO;
    
    if (self.isDefaultPlatScan) {
        [self shiftPlateReco];
    }
    
    //
    [self.session startRunning];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //移除聚焦监听
    AVCaptureDevice*camDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [camDevice removeObserver:self forKeyPath:@"adjustingFocus"];
    if (_isFoucePixel) {
        [camDevice removeObserver:self forKeyPath:@"lensPosition"];
    }
    [self.session stopRunning];
    if (_on)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self flashBtnTouched];
        });
    }
}
- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    self.navigationController.navigationBarHidden = NO;
    [_timer invalidate];
    _timer = nil;
}

//监听对焦
-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if([keyPath isEqualToString:@"adjustingFocus"]){
        self.adjustingFocus =[[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
    }
    if([keyPath isEqualToString:@"lensPosition"]){
        _isIOS8AndFoucePixelLensPosition =[[change objectForKey:NSKeyValueChangeNewKey] floatValue];
    }
}

#pragma mark - 初始化识别核心

//创建相机界面
- (void)createCameraView{
    //设置检边视图层
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
    _overView = [[UCARSmartOCROverView alloc] initWithFrame:self.view.bounds];
    _overView.backgroundColor = [UIColor clearColor];
    CGRect overSmallRect = [self setOverViewSmallRect];
    [_overView setSmallrect:overSmallRect];
    [self.view addSubview:_overView];
#endif
    
    //设置覆盖层
    [self drawShapeLayer];
    
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(15*SCALE);
        } else {
            // Fallback on earlier versions
            make.top.mas_equalTo(self.view.mas_top).offset(35*SCALE);
        }
    }];
    
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.left.mas_equalTo(20*SCALE);
        make.width.height.mas_equalTo(35*SCALE);
    }];
    
    [self.view addSubview:self.imgChooseBtn];
    [self.imgChooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(-20*SCALE);
        make.width.mas_equalTo(35*SCALE);
        make.height.mas_equalTo(35*SCALE);
    }];
    
    [self.view addSubview:self.flashTips];
    [self.flashTips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_centerY).offset(60*SCALE);
    }];
    
    [self.view addSubview:self.flashBtn];
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(21*SCALE);
        make.height.mas_equalTo(30*SCALE);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.flashTips.mas_bottom).offset(7*SCALE);
    }];
    
    
    UIImageView *tipsImg = [[UIImageView alloc] initWithImage:[UCAROCRPlatformContext imageNamed:@"tips_bg"]];
    [self.view addSubview:tipsImg];
    [tipsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth*0.667);
        make.height.mas_equalTo(30*SCALE);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_centerY).offset(16*SCALE);
    }];
    
    [self.view addSubview:self.tipsLabel];
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(tipsImg);
    }];
    
    if (!self.isHiddenToggleBtns) {
        [self.view addSubview:self.vinShiftBtn];
        [self.vinShiftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(100*SCALE);
            make.bottom.mas_equalTo(-50*SCALE);
            make.width.mas_equalTo(46*SCALE);
            make.height.mas_equalTo(72*SCALE);
        }];
        
        [self.view addSubview:self.plateShiftBtn];
        [self.plateShiftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-100*SCALE);
            make.bottom.mas_equalTo(self.vinShiftBtn);
            make.size.mas_equalTo(self.vinShiftBtn);
        }];
        
        [self resetButton:self.vinShiftBtn];
        [self resetButton:self.plateShiftBtn];
    }
}


-(void)resetButton:(UIButton*)btn
{
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height ,-btn.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-20, 0.0,0.0, -btn.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
}

//初始化相机
- (void) initialize{
    //判断摄像头授权
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        UCARAlertView *alert = [[UCARAlertView alloc]initWithTitle:@"您没有开启相机权限，请前往设置中心打开相机权限。" buttonTitles:@[@"确定"] containerView:[UIApplication sharedApplication].keyWindow clickBlock:^(NSInteger index) {
            
        }];
        alert.isMessageMustCenter = YES;
        [alert show];
        return;
    }
    
    //1.创建会话层
    self.session = [[AVCaptureSession alloc] init];
    //设置图片品质，此分辨率为最佳识别分辨率，建议不要改动
    [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
    
    //2.创建、配置输入设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices){
        if (device.position == AVCaptureDevicePositionBack){
            self.captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            self.device = device;
        }
    }
    [self.session addInput:self.captureInput];
    
    //创建、配置预览输出设备
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    [self.session addOutput:captureOutput];
    
    //3.创建、配置输出
    self.captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [self.captureOutput setOutputSettings:outputSettings];
    [self.session addOutput:self.captureOutput];
    
    //设置预览
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession: self.session];
    self.preview.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.preview setAffineTransform:CGAffineTransformMakeScale(kFocalScale, kFocalScale)];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.preview];
    
    //5.设置视频流和预览图层方向
    for (AVCaptureConnection *connection in captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                self.videoConnection = connection;
                break;
            }
        }
        if (self.videoConnection) { break; }
    }
    self.videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    
    //判断对焦方式
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        AVCaptureDeviceFormat *deviceFormat = self.device.activeFormat;
        if (deviceFormat.autoFocusSystem == AVCaptureAutoFocusSystemPhaseDetection){
            _isFoucePixel = YES;
        }
    }
}

//初始化识别核心
- (void) initOCRSource{
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
    /*
    NSDate *before = [NSDate date];
    
    _ocr = [[SmartOCR alloc] init];
    NSString *resourcePath = [NSString stringWithFormat:@"%@/",[[NSBundle mainBundle] bundlePath]];
    int init = [_ocr initOcrEngineWithDevcode:kDevcode resourcePaht:resourcePath];
    NSLog(@"初始化返回值 = %d 核心版本号 = %@", init, [_ocr getVersionNumber]);
    
    //添加主模板
    NSString *templateFilePath = [[NSBundle mainBundle] pathForResource:@"SZHY" ofType:@"xml"];
    int addTemplate = [_ocr addTemplateFile:templateFilePath];
    NSLog(@"添加主模板返回值 = %d", addTemplate);
    
    [self setScanMode];
    //设置检边参数
    [self setROI];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:before];
    NSLog(@"time：%f", time);
     */
    
    NSDate *before = [NSDate date];
    
    _ocr = [[SmartOCR alloc] init];
    NSString *resourcePath = [NSString stringWithFormat:@"%@/",[[NSBundle mainBundle] bundlePath]];
    int init = [_ocr initOcrEngineWithDevcode:kDevcode resourcePaht:resourcePath];
    NSLog(@"初始化返回值 = %d 核心版本号 = %@", init, [_ocr getVersionNumber]);
    
    //添加主模板
    NSString *templateFilePath = [[UCAROCRPlatformContext getCurrentBundle] pathForResource:@"SZHY" ofType:@"xml" inDirectory:@"vin"];
    int addTemplate = [_ocr addTemplateFile:templateFilePath];
    NSLog(@"添加主模板返回值 = %d", addTemplate);
    
    [self setScanMode];
    //设置检边参数
    [self setROI];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:before];
    NSLog(@"time：%f", time);
    
#endif
    
    
}

-(void)setScanMode
{
    //设置子模板
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
    int currentTemplate = [_ocr setCurrentTemplate:@"SV_ID_VIN_CARWINDOW"];
    NSLog(@"设置当前模板返回值 =%d",currentTemplate);
#endif


}

-(void)setImageMode
{
    //设置子模板
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
    int currentTemplate = [_ocr setCurrentTemplate:@"SV_ID_VIN_MOBILE"];
    NSLog(@"设置当前模板返回值 = %d",currentTemplate);
#endif
}

//设置检边参数
- (void) setROI{
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
    
    //设置识别区域
    CGRect rect = [self setOverViewSmallRect];
    
    CGFloat tWidth = (kFocalScale-1)*kScreenWidth*0.5;
    CGFloat tHeight = (kFocalScale-1)*kScreenHeight*0.5;
    //previewLayer上点坐标
    CGPoint pLTopPoint = CGPointMake((CGRectGetMinX(rect)+tWidth)/kFocalScale, (CGRectGetMinY(rect)+tHeight)/kFocalScale);
    CGPoint pRDownPoint = CGPointMake((CGRectGetMaxX(rect)+tWidth)/kFocalScale, (CGRectGetMaxY(rect)+tHeight)/kFocalScale);
    CGPoint pRTopPoint = CGPointMake((CGRectGetMaxX(rect)+tWidth)/kFocalScale, (CGRectGetMinY(rect)+tHeight)/kFocalScale);

    //真实图片点坐标
    CGPoint iLTopPoint = [self.preview captureDevicePointOfInterestForPoint:pRTopPoint];
    CGPoint iLDownPoint = [self.preview captureDevicePointOfInterestForPoint:pLTopPoint];
    CGPoint iRTopPoint = [self.preview captureDevicePointOfInterestForPoint:pRDownPoint];

    /*
     计算roi、
     AVCaptureVideoOrientationLandscapeRight
     AVCaptureSessionPreset1920x1080
     */
    
    int sTop,sBottom,sLeft,sRight;
    sTop = iLTopPoint.x*kResolutionWidth;
    sBottom = iRTopPoint.x*kResolutionWidth;
    sLeft = (1-iLDownPoint.y)*kResolutionHeight;
    sRight = (1-iLTopPoint.y)*kResolutionHeight;

    [_ocr setROIWithLeft:sLeft Top:sTop Right:sRight Bottom:sBottom];
    //NSLog(@"t=%d b=%d l=%d r=%d",sTop,sBottom,sLeft,sRight);
    
#endif
    
}

#pragma mark - 设置检边区域的frmae
- (CGRect )setOverViewSmallRect{
    /*
     sRect 为检边框的frame，用户可以自定义设置
     以下是demo对检边框frame的设置，仅供参考.
     */
    CGFloat tempScale = 0.667;
    //竖屏识别设置检边框frame
    CGFloat tempWidth = kScreenWidth*tempScale;
    CGFloat tempHeight = tempWidth*0.4;
    CGRect sRect = CGRectMake((kScreenWidth-tempWidth)*0.5, kScreenHeight/2-tempHeight, tempWidth,tempHeight);
    return sRect;
    
}

// 设置识别区域
- (CGRect)setRecogParametersAndCropFrameWithRect:(CGRect)rect {
    CGPoint pLTopPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPoint pLDownPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGPoint pRTopPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGPoint pRDownPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    
    
    CGFloat sTop = 0.0, sBottom = 0.0, sLeft = 0.0, sRight = 0.0;
    CGPoint iLTopPoint,iLDownPoint,iRTopPoint,iRDownPoint;
    
    
    iLTopPoint = [_preview captureDevicePointOfInterestForPoint:pRTopPoint];
    iLDownPoint = [_preview captureDevicePointOfInterestForPoint:pLTopPoint];
    iRTopPoint = [_preview captureDevicePointOfInterestForPoint:pRDownPoint];
    iRDownPoint = [_preview captureDevicePointOfInterestForPoint:pLDownPoint];
    
    CGRect recogArea;
    sTop = iLTopPoint.x*kResolutionWidth;
    sBottom = iRTopPoint.x*kResolutionWidth;
    sLeft = (1-iLDownPoint.y)*kResolutionHeight;
    sRight = (1-iLTopPoint.y)*kResolutionHeight;
    recogArea = CGRectMake(sLeft, sTop, sRight - sLeft, sBottom - sTop);

    return recogArea;
    
}


#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
//从摄像头缓冲区获取图像
#pragma mark - AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection{

    if(_isPlateReco)
    {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        
        CGRect recogArea = [self setRecogParametersAndCropFrameWithRect:[self setOverViewSmallRect]];
        //识别车牌图像
        NSArray *results = [_plateIDRecog recogImageWithBuffer:baseAddress recogCount:1 nWidth:(int)width nHeight:(int)height recogRange:recogArea confidence:75 nRotate:1 nScale:1];
        if (results.count > 0) {
            PlateResult *firstRe = results[0];
            // 停止取景
            [_session stopRunning];
            __weak typeof(self) weakSelf = self;
            //根据当前帧数据生成UIImage图像，保存图像使用
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,bytesPerRow, colorSpace, kCGBitmapByteOrder32Little |kCGImageAlphaPremultipliedFirst);
            CGImageRef quartzImage = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            CGColorSpaceRelease(colorSpace);
            /*
             该图片用于快速模式，即初始化设置为0时使用。
             */
            UIImage *img = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationUp];
            CGImageRelease(quartzImage);
            UIImage *resultImage = [self getImgByNrotate:1 :img];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(weakSelf.resultBlock)
                {
                    
                    weakSelf.resultBlock(firstRe.license,[self cropImageWithRect:firstRe.nCarRect image:resultImage]);
                    
                }
                if (!weakSelf.isHiddenToggleBtns) {
                    if (!weakSelf.jumpToScanResultPage) {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }
            });
        }
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    }
    else
    {
        //获取当前帧数据
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        
        int width = (int)CVPixelBufferGetWidth(imageBuffer);
        int height = (int)CVPixelBufferGetHeight(imageBuffer);
        //NSLog(@"_recogType == %d",_recogType);
        
        if (!self.adjustingFocus) {
            //OCR识别
            [self recogWithData:baseAddress width:width height:height SampleBuffer:sampleBuffer];
        }
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    }
}


- (void)recogWithData:(uint8_t *)baseAddress width:(int)width height:(int)height SampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    //加载图像,横屏识别RotateType传0，竖屏识别传1
    int load = [_ocr loadStreamBGRA:baseAddress Width:width Height:height RotateType:1];
    NSLog(@"%@",@(load));
    //识别
    int recog = [_ocr recognize];
    //NSLog(@"recog=%d",recog);
    if (recog == 0 || _isTakePicBtnClick)
    {
        _isTakePicBtnClick = NO;
        [_session stopRunning];
    
        //识别成功，取结果
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        //获取识别结果
        NSString *result = [_ocr getResults];
        NSLog(@"result = %@",result);
        
        //保存裁切图片
        NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imagePath = [documents[0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",result]];
        [_ocr saveImage:imagePath isRecogSuccess:recog];
        //显示图片
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (image.size.width<image.size.height)
        {
            image = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationLeft];
        }
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.takePicBtn.enabled = YES;
            if(weakSelf.resultBlock)
            {
                weakSelf.resultBlock(result,image);
                
            }
            if (!weakSelf.isHiddenToggleBtns) {
                if (!weakSelf.jumpToScanResultPage) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
            
        });
    }
}

- (void)recog:(UIImage *)image
{
    if(_isPlateReco)
    {
        // 车牌号识别
        [self carNumberRecogonize:image];
    }
    else
    {
        // vin号码识别
        [self vinNumberRecogonize:image];
    }
}

- (void)carNumberRecogonize:(UIImage *)image
{
    __weak typeof(self) weakSelf = self;
    if ([self.imageType isEqualToString:@"other"])
    {
        self.imageType = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
           [weakSelf.view ocr_makeToast:@"车牌号识别仅支持jpg格式的图片"];
            weakSelf.view.userInteractionEnabled = YES;
            [weakSelf.session startRunning];
            return;
        });
       
    }
    else
    {
        if (image.size.width > 2048*2 || image.size.height > 2048*2)
        {
           
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"图片过大，图片宽高不能大于2048*2，请选择符合要求的图片");
                weakSelf.view.userInteractionEnabled = YES;
                [weakSelf.session startRunning];
            });

            return;
        }
        UIImage *finalImg = [image fixCaptureStillImageOrientation];
        NSArray *results = [_plateIDRecog recogWithImage:finalImg recogCount:1 nRotate:5];
        if (results.count > 0)
        {
            PlateResult *firstRe = results[0];
            dispatch_async(dispatch_get_main_queue(), ^{
                // 停止取景
                [weakSelf.session stopRunning];
                if(weakSelf.resultBlock)
                {
                   
                    weakSelf.resultBlock(firstRe.license,[weakSelf cropImageWithRect:firstRe.nCarRect image:finalImg]);
                    
                }
                if (!weakSelf.isHiddenToggleBtns) {
                    if (!weakSelf.jumpToScanResultPage) {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.view.userInteractionEnabled = YES;
                [weakSelf.session startRunning];
                [weakSelf.view ocr_makeToast:@"识别失败！"];
            });
        }
    }
}



- (void)vinNumberRecogonize:(UIImage *)image
{
    __weak typeof(self) weakSelf = self;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *originalImagepath = [documentsDirectory stringByAppendingPathComponent:@"originalImage.jpg"];
    NSString *cropImagepath = [documentsDirectory stringByAppendingPathComponent:@"SV_ID_VIN_CLOUD.jpg"];
    
    //识别原图写入沙盒
    [UIImageJPEGRepresentation(image, 1.0f) writeToFile:originalImagepath atomically:YES];
    //NSLog(@"originalImagepath= %@",originalImagepath);
    
    SmartOCR *imgOcr = [[SmartOCR alloc] init];
    NSString *resourcePath = [NSString stringWithFormat:@"%@/",[[NSBundle mainBundle] bundlePath]];
    int init = [imgOcr initOcrEngineWithDevcode:kDevcode resourcePaht:resourcePath];
    NSLog(@"初始化返回值 = %d 核心版本号 = %@", init, [imgOcr getVersionNumber]);
    
    //添加主模板
    NSString *templateFilePath = [[UCAROCRPlatformContext getCurrentBundle] pathForResource:@"SZHY" ofType:@"xml" inDirectory:@"vin"];
    int addTemplate = [imgOcr addTemplateFile:templateFilePath];
    NSLog(@"添加主模板返回值 = %d", addTemplate);
    
    //设置子模板
    int currentTemplate = [imgOcr setCurrentTemplate:@"SV_ID_VIN_MOBILE"];
    NSLog(@"设置当前模板返回值 = %d",currentTemplate);
    
    //按照路径加载图片
    int loadImage = [imgOcr loadImageFile:originalImagepath RotateType:0];
    NSLog(@"加载图片返回值 = %d",loadImage);
    
    //识别
    int recog = [imgOcr recognize];
    NSLog(@"识别返回值 = %d",recog);
    
    if (recog==0) {
        //获取识别结果
        NSString *result = [imgOcr getResults];
        NSLog(@"识别结果 = %@",result);
        
        //保存裁切后图片
        int saveCrop = [imgOcr saveImage:cropImagepath isRecogSuccess:0];
        NSLog(@"保存裁切图片返回值 = %d",saveCrop);
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [self stopIn];
            [weakSelf.session startRunning];
            //显示图片
            UIImage *resultImage = [UIImage imageWithContentsOfFile:cropImagepath];
            if (resultImage.size.width<resultImage.size.height)
            {
                resultImage = [UIImage imageWithCGImage:resultImage.CGImage scale:1.0 orientation:UIImageOrientationLeft];
            }
            if(weakSelf.resultBlock)
            {
                weakSelf.resultBlock(result,resultImage);
            }
            if (!weakSelf.isHiddenToggleBtns) {
                if (!weakSelf.jumpToScanResultPage) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
        });
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.view.userInteractionEnabled = YES;
            [weakSelf.session startRunning];
            [weakSelf.view ocr_makeToast:@"识别失败！"];
        });
    }
    
}

#endif
#pragma mark - UIImagePickerDelegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController*)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [_session startRunning];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage * image=[info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
        //禁用View响应 开始UIActivityIndicatorView
        weakSelf.view.userInteractionEnabled = NO;
        NSString *urlString = url.absoluteString;
        if ([urlString containsString:@"jpg"] || [urlString containsString:@"JPG"] || [urlString containsString:@"JPEG"] || [urlString containsString:@"jpeg"])
        {
            weakSelf.imageType = @"jpg";
        }
        else
        {
            weakSelf.imageType = @"other";
        }
        [weakSelf performSelectorInBackground:@selector(recog:) withObject:image];
#endif
    }];
}


//图片格式检查
+ (NSString *)imageFormatFromImageData:(NSData *)imageData
{
    uint8_t first_byte;
    [imageData getBytes:&first_byte length:1];
    switch (first_byte) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png"; // https://www.w3.org/TR/PNG-Structure.html
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52:
            if ([imageData length] < 12) {
                return nil;
            }
            
            NSString *dataString = [[NSString alloc] initWithData:[imageData subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([dataString hasPrefix:@"RIFF"] && [dataString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            
            return nil;
    }
    return nil;
}



#pragma mark - ButtonAction

-(void)shiftPlateReco
{
    self.isPlateReco = YES;
    [self.plateShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"plateIcon-pre"] forState:UIControlStateNormal];
    [self.vinShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"vinIcon"] forState:UIControlStateNormal];
    self.titleLabel.text = plateTitle;
    self.tipsLabel.text = plateTips;
}

-(void)shiftVinReco
{
    self.isPlateReco = NO;
    [self.plateShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"plateIcon"] forState:UIControlStateNormal];
    [self.vinShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"vinIcon-pre"] forState:UIControlStateNormal];
    self.titleLabel.text = vinTitle;
    self.tipsLabel.text = vinTips;
}
//返回按钮按钮点击事件
- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openImageChoose
{
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
    [_session stopRunning];
    if (_on)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self flashBtnTouched];
        });
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    //    picker.allowsEditing=YES;
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:picker animated:YES completion:nil];
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

//点击拍照按钮
- (void) takePhoto:(UIButton *)btn{
    btn.enabled = NO;
    _isTakePicBtnClick = YES;
}

//闪光灯按钮点击事件
- (void)flashBtnTouched{

    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    if (![device hasTorch]) {
        //        NSLog(@"no torch");
    }else{
        [device lockForConfiguration:nil];
        if (!_on) {
            //关闭定时器
            [_timer setFireDate:[NSDate distantFuture]];
            [device setTorchMode: AVCaptureTorchModeOn];
            [self setExposureModeCustomEx];
            _on = YES;
            [self.flashBtn setImage:[UCAROCRPlatformContext imageNamed:@"ScanLightOn"] forState:UIControlStateNormal];
            [self.flashTips setText:flashCloseTips];
        }else{
            //开启定时器
            [_timer setFireDate:[NSDate distantPast]];
            [device setTorchMode: AVCaptureTorchModeOff];
            _on = NO;
            [self.flashBtn setImage:[UCAROCRPlatformContext imageNamed:@"ScanLightOff"] forState:UIControlStateNormal];
            [self.flashTips setText:flashOpenTips];

        }
        [device unlockForConfiguration];
    }

}
//设置曝光度
- (void)setExposureModeCustomEx{
    AVCaptureDeviceFormat *format = _device.activeFormat;
    float isoValue = 80;
    if ( isoValue < format.minISO ) {
        isoValue = format.minISO;
    } else if ( isoValue > format.maxISO ) {
        isoValue = format.maxISO;
    }
    if ([_device isExposureModeSupported:AVCaptureExposureModeCustom]) {
        if ([_device lockForConfiguration:nil]) {
            [_device setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:80/*80为测试经验值*/ completionHandler:^(CMTime syncTime) {
            }];
            [_device unlockForConfiguration];
        }
    }
}
//自动曝光
- (void)setExposureModeContinuousAutoExposureEx{
    CGRect overSmallRect = [self setOverViewSmallRect];
    CGPoint cameraPoint= [_preview captureDevicePointOfInterestForPoint:CGPointMake(CGRectGetMidX(overSmallRect), CGRectGetMidY(overSmallRect))];
    if ([_device isExposurePointOfInterestSupported]) {
        if ([_device lockForConfiguration:nil]) {
            [_device setExposurePointOfInterest:cameraPoint];
            [_device unlockForConfiguration];
        }
    }
    if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        if ([_device lockForConfiguration:nil]) {
            [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [_device unlockForConfiguration];
        }
    }
}

//对焦
- (void)fouceMode{
    NSError *error;
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
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

//获取摄像头位置
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices){
        if (device.position == position){
            return device;
        }
    }
    return nil;
}

//隐藏状态栏
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)addAnimation
{
    CGRect overSmallRect = [self setOverViewSmallRect];
    //扫描线
    UIImageView *_lineView = [[UIImageView alloc]init];
    _lineView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:_lineView];
    int lineW = 2;
    _lineView.image = [UIImage imageNamed:@"horizontal_line.png"];
    _lineView.frame = CGRectMake(CGRectGetMinX(overSmallRect), CGRectGetMinY(overSmallRect), CGRectGetWidth(overSmallRect), lineW);
    NSNumber *b = [NSNumber numberWithFloat:0];
    NSNumber *e = [NSNumber numberWithFloat:(int)(CGRectGetHeight(overSmallRect)-lineW)];
    CABasicAnimation *animation = [self moveYTime:1 fromBegin:b  toEnd:e rep:OPEN_MAX];
    [_lineView.layer addAnimation:animation forKey:@"LineAnimation"];
}

- (CABasicAnimation *)moveYTime:(float)time fromBegin:(NSNumber *)nBegin toEnd:(NSNumber *)nEnd rep:(int)rep{
    
    NSString *trans = @"transform.translation.y";

    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:trans];
    [animationMove setFromValue:nBegin];
    [animationMove setToValue:nEnd];
    animationMove.duration = time;
    animationMove.repeatCount  = rep;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}
//重绘透明部分
- (void) drawShapeLayer{
    //设置覆盖层
    if (!self.maskWithHole) {
        self.maskWithHole = [CAShapeLayer layer];
    }
    
    // Both frames are defined in the same coordinate system
    CGRect biggerRect = self.view.bounds;
    CGFloat offset = 1.0f;
    if ([[UIScreen mainScreen] scale] >= 2) {
        offset = 0.5;
    }
    
    //设置检边视图层
    CGRect smallFrame = [self setOverViewSmallRect];
    CGRect smallerRect = CGRectInset(smallFrame, -offset, -offset) ;
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMaxY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(smallerRect), CGRectGetMaxY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMinY(smallerRect))];
    [self.maskWithHole setPath:[maskPath CGPath]];
    [self.maskWithHole setFillRule:kCAFillRuleEvenOdd];
    [self.maskWithHole setFillColor:[[UIColor colorWithWhite:0 alpha:0.5] CGColor]];
    [self.view.layer addSublayer:self.maskWithHole];
    [self.view.layer setMasksToBounds:YES];
}


#pragma mark - 车牌识别相关
//初始化识别核心
- (void) initRecog
{
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
    _plateIDRecog = [[PlateIDOCR alloc] init];
    /*在此填写开发码，初始化识别核心*/
    int init = [_plateIDRecog initPalteIDWithDevcode:@"56WE5BEE5LYY6L2" RecogType:0];
    NSLog(@"\n核心初始化返回值 = %d\n返回值为0成功 其他失败\n\n常见错误：\n-10601 开发码错误\n核心初始化方法- (int) initPalteIDWithDevcode: (NSString *)devcode RecogType:(int) type;参数为开发码\n\n-10602 Bundle identifier错误\n-10605 Bundle display name错误\n-10606 CompanyName错误\n请检查授权文件（wtproject.lsc）绑定的信息与Info.plist中设置是否一致!!!",init);
    
    //车牌识别设置
    [_plateIDRecog setPlateFormat:[self getPlateFormat]];
#endif
}

//车牌识别设置
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
- (PlateFormat *)getPlateFormat {
    PlateFormat *plateFormat = [[PlateFormat alloc] init];
    
    plateFormat.nOCR_Th = 2;
    plateFormat.nPlateLocate_Th = 5;
    plateFormat.armpolice = 1;
    plateFormat.armpolice2 = 1;
    plateFormat.embassy = 1;
    plateFormat.individual = 1;
    plateFormat.tworowarmy = 1;
    plateFormat.tworowyellow = 1;
    plateFormat.consulate = 1;
    plateFormat.newEnergy = 1;
    return plateFormat;
}
#endif


- (UIImage *)getImgByNrotate:(int)nRotate :(UIImage *)image
{
    
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (nRotate) {
        case 3:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case 1:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case 2:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    //    CGContextRelease(context);
    UIGraphicsEndImageContext();
    return newPic;
}

- (UIImage *)cropImageWithRect: (CGRect) rect image:(UIImage *)image
{
    NSLog(@"%@", NSStringFromCGRect(rect));
    CGImageRef imageRef = image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, rect);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, rect, subImageRef);
    UIImage *newImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    return newImage;
}

@end
