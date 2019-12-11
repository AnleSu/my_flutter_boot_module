//
//  ZCScanView.m
//  ZCBusiness
//
//  Created by ZhangYuqing on 2019/3/3.
//  Copyright © 2019 UCAR. All rights reserved.
//

// import分组次序：Frameworks、Services、UI
#import "UCARScanView.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>

/** 扫描内容的Y值 */
#define scanContent_Y self.frame.size.height * 0.24
/** 扫描内容的X值 */
#define scanContent_X self.frame.size.width * 0.15
#define layerBounds    [UIScreen mainScreen].bounds
// iphone X Series（x/xs/xr/xs max）
#define iphoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ([[UIScreen mainScreen] currentMode].size.height == 2436 || [[UIScreen mainScreen] currentMode].size.height == 1792 || [[UIScreen mainScreen] currentMode].size.height == 2688 || [[UIScreen mainScreen] currentMode].size.height == 1624) : NO)
// 导航栏
#define UI_NAVIGATION_BAR_HEIGHT        (44.0)
#define UI_STATUS_BAR_HEIGHT            (iphoneX ? 44.0 : 20.0)
#define UI_NAVIGATION_STATUS_BAR_HEIGHT (UI_NAVIGATION_BAR_HEIGHT + UI_STATUS_BAR_HEIGHT)

// 屏幕宽高
#define UI_SCREEN_WIDTH                    ([[UIScreen mainScreen] bounds].size.width)
#define UI_SCREEN_HEIGHT                   ([[UIScreen mainScreen] bounds].size.height)

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface UCARScanView ()<AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureDevice *_avDevice; //摄像设备
    AVCaptureSession *_avSession; //输入输出的中间桥梁
}
@property (strong,nonatomic) UIButton *backButton;
@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) UIView *navigationBar;
@property (strong,nonatomic) UIButton *rightButton;
@property (strong,nonatomic) UIImageView *lineImgView;
@end

@implementation UCARScanView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        [self addSubLayerView];
    }
    return self;
}

- (void)addSubLayerView
{
    //设置相机layer
    [self showAV];
    //绘制扫码框layer层
    [self setupSubView];
    [self createTitleLabelAndBackButton];
}


+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (void)dealloc {
    NSLog(@"%@ - dealloc", NSStringFromClass([self class]));
}

- (void)createTitleLabelAndBackButton
{
    CGFloat offset = iphoneX ? UI_STATUS_BAR_HEIGHT : 20 ;
    self.navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, offset, UI_SCREEN_WIDTH, UI_NAVIGATION_BAR_HEIGHT)];
    [self addSubview:self.navigationBar];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[self getImageWithName:@"ScanBackButtonIcon"] forState:UIControlStateNormal];
    [self.navigationBar addSubview:self.backButton];
    self.backButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rightButton setTitle:@"相册" forState:UIControlStateNormal];
    [self.navigationBar addSubview:self.rightButton];
    
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(55, 55));
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"二维码/条码";
    [self.navigationBar addSubview:self.titleLabel];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.backButton.mas_right);
        make.right.lessThanOrEqualTo(self.rightButton.mas_left);
        make.center.equalTo(self.navigationBar);
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(55, 55));
    }];
    
    [self.backButton addTarget:self action:@selector(backButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark 创建扫码框(*1)及遮罩(*4)
-(void)setupSubView
{
    //1.绘制扫码框
    UIView *scanContent_layer = [[UIView alloc] init];
    CGFloat scanContent_layerX = scanContent_X;
    CGFloat scanContent_layerY = scanContent_Y;
    CGFloat scanContent_layerW = layerBounds.size.width - 2 * scanContent_X;
    CGFloat scanContent_layerH = scanContent_layerW;
    scanContent_layer.frame = CGRectMake(scanContent_layerX, scanContent_layerY, scanContent_layerW, scanContent_layerH);
    scanContent_layer.layer.borderColor = [UIColor clearColor].CGColor;
    scanContent_layer.layer.borderWidth = 0.8;
    scanContent_layer.backgroundColor = [UIColor clearColor];
    [self addSubview:scanContent_layer];
    
    //2.1 顶部layer的创建
    UIView *top_layer = [[UIView alloc] init];
    CGFloat top_layerX = 0;
    CGFloat top_layerY = 0;
    CGFloat top_layerW = self.frame.size.width;
    CGFloat top_layerH = scanContent_layerY;
    top_layer.frame = CGRectMake(top_layerX, top_layerY, top_layerW, top_layerH);
    top_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self addSubview:top_layer];
    

    //2.2 左侧layer的创建
    UIView *left_layer = [[UIView alloc] init];
    CGFloat left_layerX = 0;
    CGFloat left_layerY = scanContent_layerY;
    CGFloat left_layerW = scanContent_X;
    CGFloat left_layerH = scanContent_layerH;
    left_layer.frame = CGRectMake(left_layerX, left_layerY, left_layerW, left_layerH);
    left_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self addSubview:left_layer];
    
    
    //2.3 右侧layer创建
    UIView *right_layer = [[UIView alloc]init];
    CGFloat right_layerX = layerBounds.size.width - scanContent_X;
    CGFloat right_layerY = scanContent_layerY;
    CGFloat right_layerW = scanContent_X;
    CGFloat right_layerH = scanContent_layerH;
    right_layer.frame = CGRectMake(right_layerX, right_layerY, right_layerW, right_layerH);
    right_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self addSubview:right_layer];
    
    //2.4 底部layer创建
    UIView *bottom_layer = [[UIView alloc] init];
    CGFloat bottom_layerX = 0;
    CGFloat bottom_layerY = CGRectGetMaxY(scanContent_layer.frame);
    CGFloat bottom_layerW = self.frame.size.width;
    CGFloat bottom_layerH = self.frame.size.height - bottom_layerY;
    bottom_layer.frame = CGRectMake(bottom_layerX, bottom_layerY, bottom_layerW, bottom_layerH);
    bottom_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self addSubview:bottom_layer];
    

    //扫描边角imageView的创建
    //3.1 左上侧的image
    CGFloat margin = 10;
    
    UIImage *left_image = [self getImageWithName:@"ScanLeftTop"];
    UIImageView *left_imageView = [[UIImageView alloc] init];
    CGFloat left_imageViewX = CGRectGetMinX(scanContent_layer.frame) - left_image.size.width * 0.5 + margin;
    CGFloat left_imageViewY = CGRectGetMinY(scanContent_layer.frame) - left_image.size.width * 0.5 + margin;
    CGFloat left_imageViewW = left_image.size.width;
    CGFloat left_imageViewH = left_image.size.height;
    left_imageView.frame = CGRectMake(left_imageViewX + 3, left_imageViewY + 3, left_imageViewW, left_imageViewH);
    left_imageView.image = left_image;
    [self addSubview:left_imageView];
    
    //3.2 右上侧的image
    UIImage *right_image = [self getImageWithName:@"ScanRightTop"];
    UIImageView *right_imageView = [[UIImageView alloc] init];
    CGFloat right_imageViewX = CGRectGetMaxX(scanContent_layer.frame) - right_image.size.width * 0.5 - margin;
    CGFloat right_imageViewY = left_imageView.frame.origin.y;
    CGFloat right_imageViewW = left_image.size.width;
    CGFloat right_imageViewH = left_image.size.height;
    right_imageView.frame = CGRectMake(right_imageViewX-3, right_imageViewY, right_imageViewW, right_imageViewH);
    right_imageView.image = right_image;
    [self addSubview:right_imageView];
    
    //3.3 左下侧的image
    UIImage *left_image_down = [self getImageWithName:@"ScanLeftBottom"];
    UIImageView *left_imageView_down = [[UIImageView alloc] init];
    CGFloat left_imageView_downX = left_imageView.frame.origin.x;
    CGFloat left_imageView_downY = CGRectGetMaxY(scanContent_layer.frame) - left_image_down.size.width * 0.5 - margin;
    CGFloat left_imageView_downW = left_image.size.width;
    CGFloat left_imageView_downH = left_image.size.height;
    left_imageView_down.frame = CGRectMake(left_imageView_downX, left_imageView_downY, left_imageView_downW, left_imageView_downH);
    left_imageView_down.image = left_image_down;
    [self addSubview:left_imageView_down];
    
    //3.4 右下侧的image
    UIImage *right_image_down = [self getImageWithName:@"ScanRightBottom"];
    UIImageView *right_imageView_down = [[UIImageView alloc] init];
    CGFloat right_imageView_downX = right_imageView.frame.origin.x;
    CGFloat right_imageView_downY = left_imageView_down.frame.origin.y;
    CGFloat right_imageView_downW = left_image.size.width;
    CGFloat right_imageView_downH = left_image.size.height;
    right_imageView_down.frame = CGRectMake(right_imageView_downX, right_imageView_downY, right_imageView_downW, right_imageView_downH);
    right_imageView_down.image = right_image_down;
    [self addSubview:right_imageView_down];
    
    
    //4 提示Label
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.backgroundColor = UIColorFromRGB(0x464646);
    CGFloat promptLabelY = CGRectGetMaxY(scanContent_layer.frame) + 10;
    CGFloat promptLabelH = 30;
    promptLabel.frame = CGRectMake(scanContent_layerX, promptLabelY,scanContent_layerW,promptLabelH);
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
    promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    promptLabel.text = @"请将二维码/条码放入框内,即可扫描";
    promptLabel.layer.cornerRadius = 15.0f;
    promptLabel.clipsToBounds = YES;
    [self addSubview:promptLabel];
    
    //5 添加闪光灯按钮
    UIImage *light_open_img = [self getImageWithName:@"QRScanLightOff"];
    UIImage *light_off_img = [self getImageWithName:@"QRScanLightOn"];
    UIButton *light_button = [[UIButton alloc] init];
    CGFloat light_buttonX = 0;
    CGFloat light_buttonY = scanContent_Y + scanContent_layerH - scanContent_X + 20;
    CGFloat light_buttonW = light_open_img.size.width;
    CGFloat light_buttonH = light_open_img.size.height;
    light_button.frame = CGRectMake(light_buttonX, light_buttonY, light_buttonW, light_buttonH);
    light_button.center = CGPointMake(self.center.x, light_buttonY);
    [light_button setImage:light_open_img forState:UIControlStateNormal];
    [light_button setImage:light_off_img forState:UIControlStateSelected];
    self.lightButton = light_button;
    [light_button addTarget:self action:@selector(light_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:light_button];
    
    //6 添加line
    UIImage *lineimg = [self getImageWithName:@"ScanLineImage"];
    _lineImgView = [[UIImageView alloc] init];
    _lineImgView.image = lineimg;
    CGFloat lineimgViewX = scanContent_X;
    CGFloat lineimgViewY = scanContent_Y;
    CGFloat lineimgViewW = scanContent_layerW;
    CGFloat lineimgViewH = lineimg.size.height;
    _lineImgView.frame = CGRectMake(lineimgViewX, lineimgViewY,lineimgViewW,lineimgViewH);
    [self addSubview:_lineImgView];

}

- (void)startScanLineAnimation
{
    // line移动的范围为 一个扫码框的高度(由于图片问题再减去图片的高度)
    CGFloat scanContent_layerW = layerBounds.size.width - 2 * scanContent_X;
    CGFloat scanContent_layerH = scanContent_layerW;
    CABasicAnimation *lineAnimation = [self animationWith:@(0) toValue:@(scanContent_layerH - self.lineImgView.frame.size.height) repCount:MAXFLOAT duration:1.5f];
    [self.lineImgView.layer addAnimation:lineAnimation forKey:@"LineImgViewAnimation"];
}


-(void)showAV
{
    //1.获取摄像设备
    _avDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_avDevice error:nil];
    
    //3.创建输出流
    AVCaptureMetadataOutput *metdataOutput = [[AVCaptureMetadataOutput alloc] init];
    //设置代理 在主线程刷新
    [metdataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //3.1 设置扫码框作用范围 (由于扫码时系统默认横屏关系, 导致作用框原点变为我们绘制的框的右上角,而不是左上角) 且参数为比率不是像素点
    metdataOutput.rectOfInterest = CGRectMake(scanContent_Y/layerBounds.size.height, scanContent_X/layerBounds.size.width, (layerBounds.size.width - 2 * scanContent_X)/layerBounds.size.height, (layerBounds.size.width - 2 * scanContent_X)/layerBounds.size.width);
    
    
    //4.初始化连接对象
    _avSession = [[AVCaptureSession alloc] init];
    //设置高质量采集率
    [_avSession setSessionPreset:AVCaptureSessionPresetHigh];
    //组合
    if (input) {
        [_avSession addInput:input];
    }else {
        
    }
    
    [_avSession addOutput:metdataOutput];
    
    
    //设置扫码格式支持的码(一定要在 session 添加 addOutput之后再设置 否则会爆)
    metdataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,//二维码
          AVMetadataObjectTypeEAN13Code,
          AVMetadataObjectTypeEAN8Code,
          AVMetadataObjectTypeUPCECode,
          AVMetadataObjectTypeCode39Code,
          AVMetadataObjectTypeCode39Mod43Code,
          AVMetadataObjectTypeCode93Code,
          AVMetadataObjectTypeCode128Code,
          AVMetadataObjectTypePDF417Code];
    //展示layer
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_avSession];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.layer.bounds;
    [self.layer addSublayer:layer];    
    [_avSession startRunning];
}


#pragma mark - 扫码line滑动动画
- (CABasicAnimation*)animationWith:(id)fromValue toValue:(id)toValue repCount:(CGFloat)repCount duration:(CGFloat)duration{
    
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    lineAnimation.fromValue = fromValue;
    lineAnimation.toValue = toValue;
    lineAnimation.repeatCount = repCount;
    lineAnimation.duration = duration;
    lineAnimation.fillMode = kCAFillModeForwards;
    lineAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return lineAnimation;
}

- (void)removeAnimationAboutScan
{
    [_lineImgView.layer removeAnimationForKey:@"LineImgViewAnimation"];
    _lineImgView.hidden = YES;
}

#pragma mark - - - 照明灯的点击事件
- (void)light_buttonAction:(UIButton *)button
{
    if (button.selected == NO)
    { // 点击打开照明灯
        [self turnOnLight:YES];
        button.selected = YES;
    }
    else
    { // 点击关闭照明灯
        [self turnOnLight:NO];
        button.selected = NO;
    }
}



#pragma mark - 开关灯功能
- (void)turnOnLight:(BOOL)on
{
    //1.是否存在手电功能
    if ([_avDevice hasTorch])
    {
        //2.锁定当前设备为使用者
        [_avDevice lockForConfiguration:nil];
        //3.开关手电筒
        if (on)
        {
            [_avDevice setTorchMode:AVCaptureTorchModeOn];
        }
        else
        {
            [_avDevice setTorchMode: AVCaptureTorchModeOff];
        }
        //4.使用完成后解锁
        [_avDevice unlockForConfiguration];
    }
}



#pragma mark - 获取码值 - 代理方法(AVCaptureMetadataOutputObjectsDelegate)
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects.count>0)
    {
        //停止扫描
        [_avSession stopRunning];
        //取消line动画
        [self removeAnimationAboutScan];
        //输出扫码字符串
        if ([_delegate respondsToSelector:@selector(ZCScanViewOutputMetadataObjects:)]) {
            [_delegate ZCScanViewOutputMetadataObjects:metadataObjects];
        }
    }
}

- (void)backButtonDidClick
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(popToViewController)])
    {
        [self.delegate popToViewController];
    }
    
}

- (void)rightButtonClick
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(showTheAlbum)])
    {
        [self.delegate showTheAlbum];
    }
}

- (UIImage *)getImageWithName:(NSString *)imageName
{
    NSBundle *bundle = [self getPodsResouceBundle];
    UIImage * image = [self zccomponment_imageNamed:imageName inBundle:bundle];
    return image;
}

- (NSBundle *)getPodsResouceBundle
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleUrl = [bundle URLForResource:@"ZCQRCodeComponent" withExtension:@"bundle"];
    NSBundle *finaleBundle = [NSBundle bundleWithURL:bundleUrl];
    return finaleBundle;
}

- (UIImage *)zccomponment_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
#elif __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:@"png"]];
#else
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:@"png"]];
    }
#endif
}

- (void)setTitleString:(NSString *)titleString
{
    self.titleLabel.text = titleString;
}

- (void)startOrStopScaning:(BOOL)isStartScan
{
    if (_avSession)
    {
        if (isStartScan)
        {
            [_avSession startRunning];
        }
        else
        {
            [_avSession stopRunning];
        }
    }
}
@end
