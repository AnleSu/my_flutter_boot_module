//
//  TakePhotoVC.m
//  KoalaPhoto
//
//  Created by 张英堂 on 14/11/13.
//  Copyright (c) 2014年 visionhacker. All rights reserved.
//

#import "MGLiveDetectViewController.h"
#import "UCARLive_Color.h"

static CGFloat topToTitle = iPhoneX ? 82*UCARLIVE_SCALE : 38*UCARLIVE_SCALE;
static CGFloat titleHeight = 22*UCARLIVE_SCALE;
static CGFloat titleToTips = 20*UCARLIVE_SCALE;
static CGFloat tipsHeight = 17*UCARLIVE_SCALE;
static CGFloat tipsToCount = 20*UCARLIVE_SCALE;
static CGFloat countHeight = 23*UCARLIVE_SCALE;
static CGFloat countToFace = 20*UCARLIVE_SCALE;
static CGFloat faceHeight = 234*UCARLIVE_SCALE;
static CGFloat faceToWave = 30*UCARLIVE_SCALE;
static CGFloat waveHeight = 55*UCARLIVE_SCALE;
static CGFloat bottomY = topToTitle + titleHeight + titleToTips + tipsHeight + tipsToCount + countHeight + countToFace + faceHeight + faceToWave + waveHeight;

@interface MGLiveDetectViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *downCountLabel;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIView *errorView;
@property (nonatomic, strong) UIView *headerAreaView;
@property (nonatomic, strong) UIImageView *headerAreaBgImageView;
@property (nonatomic, strong) UIImageView *waveImageView;

@property (nonatomic, assign) BOOL isErroring;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger secondCount;
@property (nonatomic, assign) NSInteger secondCurrent;

@property (nonatomic, assign) BOOL isStop;

@end

@implementation MGLiveDetectViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatView];
}

/** 检查设置错误
 *  @return 错误类型
 */
- (MGLiveSettingErrorType)checkLiveDetectionSetting {
    if (nil == self.videoManager) {
        return MGLiveSettingErrorVideoError;
    }
    if (nil == self.videoManager.videoDelegate) {
        return MGLiveSettingErrorVideoBlockError;
    }
    if (nil == self.liveManager) {
        return MGLiveSettingErrorDetectionError;
    }
    if (nil == self.liveManager.delegate) {
        return MGLiveSettingErrorDetectionDelegateError;
    }
    return MGLiveSettingErrorNone;
}

/* 配置错误 */
- (void)MGSettingErrorAlarm{
    MGLiveSettingErrorType settingError = [self checkLiveDetectionSetting];
    if (settingError != MGLiveSettingErrorNone) {
        NSString *settringErrorMessage = [NSString stringWithFormat:@"MGLiveSettingErrorType: %zi", settingError];
        NSLog(@"settringErrorMessage = %@",settringErrorMessage);
        if (self.settingError) {
            self.settingError(settingError, self.navigationController);
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setUpCameraLayer];
    [self.videoManager startRecording];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.isStop == YES) {
        [self stopDetect];
        return;
    }
    [self willStatLiveness];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self.liveManager stopDetectionQuality];
    [self stopVideoWriter];
    [self stopCount];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topToTitle, UCARLIVE_SCREEN_WIDTH, titleHeight)];
        _titleLabel.font = [UIFont systemFontOfSize:(24*UCARLIVE_SCALE) weight:UIFontWeightRegular];
        _titleLabel.textColor = UCARLIVE_UIColorFromRGB(0x404041);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"安全验证";
    }
    return _titleLabel;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (topToTitle + titleHeight + titleToTips), UCARLIVE_SCREEN_WIDTH, tipsHeight)];
        _tipsLabel.font = [UIFont systemFontOfSize:(18*UCARLIVE_SCALE)];
        _tipsLabel.textColor = UCARLIVE_UIColorFromRGB(0x404041);
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.text = @"正对手机，将脸显示在检测框中";
    }
    return _tipsLabel;
}

- (UILabel *)downCountLabel {
    if (!_downCountLabel) {
        _downCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (topToTitle + titleHeight + titleToTips + tipsHeight + tipsToCount), UCARLIVE_SCREEN_WIDTH, countHeight)];
        _downCountLabel.textColor = UCARLIVE_UIColorFromRGB(0x3fb268);
        _downCountLabel.textAlignment = NSTextAlignmentCenter;
        NSString *title = [NSString stringWithFormat:@"%ldS",(long)self.secondCurrent];
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [attributedTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30*UCARLIVE_SCALE] range:NSMakeRange(0, title.length-1)];
        [attributedTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20*UCARLIVE_SCALE] range:NSMakeRange(title.length-1, 1)];
        _downCountLabel.attributedText = attributedTitle;
    }
    return _downCountLabel;
}

- (UIView *)headerAreaView {
    if (!_headerAreaView) {
        _headerAreaView = [[UIView alloc] initWithFrame:CGRectMake((UCARLIVE_SCREEN_WIDTH - faceHeight) / 2, (topToTitle + titleHeight + titleToTips + tipsHeight + tipsToCount + countHeight + countToFace), faceHeight, faceHeight)];
        _headerAreaView.backgroundColor = [UIColor clearColor];
        _headerAreaView.layer.cornerRadius = faceHeight / 2;
        _headerAreaView.layer.masksToBounds = YES;
        _headerAreaView.clipsToBounds = YES;
    }
    return _headerAreaView;
}

- (UIImageView *)headerAreaBgImageView {
    if (!_headerAreaBgImageView) {
        _headerAreaBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, faceHeight, faceHeight)];
        _headerAreaBgImageView.backgroundColor = [UIColor clearColor];
        _headerAreaBgImageView.image = [MGLiveBundle LiveImageWithName:@"headerAreaView"];
        _headerAreaBgImageView.clipsToBounds = YES;
        [_headerAreaBgImageView setContentMode:UIViewContentModeScaleToFill];
    }
    return _headerAreaBgImageView;
}

- (UIImageView *)headerView {
    if(!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, faceHeight, faceHeight)];
        [_headerView setContentMode:UIViewContentModeScaleToFill];
    }
    return _headerView;
}

- (UIView *)errorView {
    if (!_errorView) {
        _errorView = [[UIView alloc] initWithFrame:CGRectMake(0, 7*UCARLIVE_SCALE, faceHeight, 0)];
        _errorView.backgroundColor = UCARLIVE_UIAlphaColorFromRGB(0x000000, 0.5);
        CGFloat width = faceHeight;
        CGFloat height = 70*UCARLIVE_SCALE;
        CGRect bounds = CGRectMake(0, 0, width, height);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(faceHeight / 2, faceHeight / 2)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = bounds;
        maskLayer.path = maskPath.CGPath;
        maskLayer.masksToBounds = YES;
        _errorView.layer.mask = maskLayer;
        _errorView.clipsToBounds = YES;
    }
    return _errorView;
}

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*UCARLIVE_SCALE, 35*UCARLIVE_SCALE, faceHeight-30*UCARLIVE_SCALE, 20*UCARLIVE_SCALE)];
        _errorLabel.font = [UIFont systemFontOfSize:(17*UCARLIVE_SCALE)];
        _errorLabel.textColor = UCARLIVE_UIColorFromRGB(0xffffff);
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        _errorLabel.clipsToBounds = YES;
    }
    return _errorLabel;
}

- (UIImageView *)waveImageView {
    if (!_waveImageView) {
        _waveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (topToTitle + titleHeight + titleToTips + tipsHeight + tipsToCount + countHeight + countToFace + faceHeight + faceToWave), UCARLIVE_SCREEN_WIDTH, waveHeight)];
        _waveImageView.backgroundColor = [UIColor clearColor];
        _waveImageView.image = [MGLiveBundle LiveImageWithName:@"wave"];
        [_waveImageView setContentMode:UIViewContentModeScaleToFill];
    }
    return _waveImageView;
}

/** 创建界面 */
- (void)creatView {
    
    if (self.timeOutSecond == 0) {
        self.secondCount = 60;
    } else {
        self.secondCount = self.timeOutSecond;
    }
    
    self.secondCurrent = self.secondCount;
    
    self.view.backgroundColor = UCARLIVE_UIColorFromRGB(0xebebeb);
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.downCountLabel];
    
    [self.view addSubview:self.headerAreaView];
    [self.headerAreaView addSubview:self.headerView];
    [self.headerAreaView addSubview:self.headerAreaBgImageView];
    
    [self.headerAreaView addSubview:self.errorView];
    [self.headerAreaView insertSubview:self.errorView belowSubview:self.headerAreaBgImageView];
    [self.errorView addSubview:self.errorLabel];
    
    [self.view addSubview:self.waveImageView];
    
    self.bottomView = [[MGDefaultBottomManager alloc]
                       initWithFrame:CGRectMake(0, bottomY, UCARLIVE_SCREEN_WIDTH, (UCARLIVE_SCREEN_HEIGHT-bottomY))];

    [self.view addSubview:self.bottomView];
    
}

/** 开启活体检测流程 */
- (void)liveFaceDetection{
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted == NO) {
                [self liveDetectionFinish:DETECTION_FAILED_TYPE_CAMERA checkOK:NO liveDetectionType:MGLiveDetectionTypeAll];
            } else {
                NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
                if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                    [self liveDetectionFinish:DETECTION_FAILED_TYPE_CAMERA checkOK:NO liveDetectionType:MGLiveDetectionTypeAll];
                }
                else {
                    [super liveFaceDetection];
                    
                    [self MGSettingErrorAlarm];
                    
                    self.isErroring = NO;
                    
                    [self.liveManager starDetection];
                    [self.videoManager startRecording];
                    [self startCount];
                    
                }
            }
        });
    }];
}

-(void)qualitayErrorMessage:(NSString *)error{
    [super qualitayErrorMessage:error];
    [self showErrorView:error];
}

/** 加载图层预览 */
- (void)setUpCameraLayer
{
    if (!self.previewLayer) {
        CALayer * viewLayer = [self.headerAreaView layer];
        CGRect layerbounds = viewLayer.bounds;
        self.videoManager.videoPreview.frame = layerbounds;
        
        self.previewLayer = self.videoManager.videoPreview;
        [viewLayer insertSublayer:self.previewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
    }
    [self.view bringSubviewToFront:self.bottomView];
}

/** 播放动作提示动画 */
- (void)starAnimation:(MGLivenessDetectionType )type
                 step:(NSInteger)step
              timeOut:(NSUInteger)timeOut{
    [super starAnimation:type step:step timeOut:timeOut];
    
    [self.bottomView willChangeAnimation:type outTime:timeOut currentStep:step];
    [self.bottomView startRollAnimation];
}

/** 活体检测结束处理 */
- (void)liveDetectionFinish:(MGLivenessDetectionFailedType)type checkOK:(BOOL)check liveDetectionType:(MGLiveDetectionType)detectionType{
    [super liveDetectionFinish:type checkOK:check liveDetectionType:detectionType];
    [self.liveManager stopDetectionQuality];
    [self.videoManager stopRceording];
    [self stopCount];
}

- (void)showErrorView:(NSString *)error {
    
    if ([error isEqualToString:@""] || error == nil) {
        if (self.isErroring == YES) {
            [UIView animateWithDuration:2 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGRect rect = self.errorView.frame;
                rect.size.height = 0;
                self.errorView.frame = rect;
            } completion:^(BOOL finished) {
                self.isErroring = NO;
            }];
        }
    }
    else {
        if (self.isErroring == NO) {
            self.errorLabel.text = error;
            [UIView animateWithDuration:2 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGRect rect = self.errorView.frame;
                rect.size.height = 70;
                self.errorView.frame = rect;
            } completion:^(BOOL finished) {
                self.isErroring = YES;
            }];
        }
        else {
            self.errorLabel.text = error;
        }
    }
}

#pragma mark - Timer

- (void)initTimer {
    if (self.timer == nil) {
        self.secondCurrent = self.secondCount;
        NSString *title = [NSString stringWithFormat:@"%ldS",(long)self.secondCurrent];
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [attributedTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30*UCARLIVE_SCALE] range:NSMakeRange(0, title.length-1)];
        [attributedTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20*UCARLIVE_SCALE] range:NSMakeRange(title.length-1, 1)];
        _downCountLabel.attributedText = attributedTitle;
        self.timer = [NSTimer timerWithTimeInterval:1
                                             target:self
                                           selector:@selector(timeChange)
                                           userInfo:nil
                                            repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
    else {
        [self stopCount];
        [self initTimer];
    }
}

- (void)timeChange {
    if (self.secondCurrent == 0) {
        [self.timer invalidate];
        self.timer = nil;
    } else {
        self.secondCurrent--;
    }
    if (self.secondCurrent == 0) {
        self.downCountLabel.text = @"";
        [self liveDetectionFinish:DETECTION_FAILED_TYPE_TIMEOUT checkOK:NO liveDetectionType:MGLiveDetectionTypeAll];
    } else {
        NSString *title = [NSString stringWithFormat:@"%ldS",(long)self.secondCurrent];
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [attributedTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30*UCARLIVE_SCALE] range:NSMakeRange(0, title.length-1)];
        [attributedTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20*UCARLIVE_SCALE] range:NSMakeRange(title.length-1, 1)];
        _downCountLabel.attributedText = attributedTitle;
    }
}

- (void) restartDetect {
    [super restartDetect];
    self.isStop = NO;
    [self willStatLiveness];
}

- (void)stopDetect {
    [super stopDetect];
    self.isStop = YES;
    [self.liveManager stopDetectionQuality];
    [self.videoManager stopRceording];
    [self stopCount];
}

- (void)startCount {
    [self initTimer];
}

- (void)stopCount {
    if (self.timer != nil) {
        self.secondCurrent = 0;
        [self.timer invalidate];
        self.timer = nil;
    }
    self.downCountLabel.text = @"";
    if (self.isErroring == YES) {
        [UIView animateWithDuration:2 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRect rect = self.errorView.frame;
            rect.size.height = 0;
            self.errorView.frame = rect;
        } completion:^(BOOL finished) {
            self.isErroring = NO;
        }];
    }
}

@end
