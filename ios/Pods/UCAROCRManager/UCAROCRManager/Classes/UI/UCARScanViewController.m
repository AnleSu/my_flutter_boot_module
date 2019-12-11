//
//  UCAROCRViewController.m
//  Masonry
//
//  Created by Link on 2019/8/12.
//

#import "UCARScanViewController.h"
#import "UCARSmartOCRCameraViewController.h"
#import "UCARQRCodeScanViewController.h"
#import "OCRMacroUI.h"
#import "UCAROCRPlatformContext.h"
#import <Masonry/Masonry.h>
#import <Masonry/NSArray+MASAdditions.h>


static const NSString *kScanTypeName        =    @"ScanTypeName";
static const NSString *kScanViewController  =    @"kScanViewController";
static const NSString *kScanButton          =    @"ScanButton";


@interface UCARScanViewController () <UCARQRCodeScanViewControllerDelegate>

@property (nonatomic, readwrite, strong) UCARQRCodeScanViewController *qrScanCtrl;

@property (nonatomic, readwrite, strong) UCARSmartOCRCameraViewController *ocrCtrl;

@property (nonatomic, readwrite, strong) NSMutableArray *scanInfos;

//按钮
@property (nonatomic, readwrite, strong) UIButton *plateShiftBtn;
@property (nonatomic, readwrite, strong) UIButton *vinShiftBtn;
@property (nonatomic, readwrite, strong) UIButton *qrShiftBtn;

//addChildViewController
@property (nonatomic, readwrite, strong) UIViewController *curViewController;
@end

@implementation UCARScanViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    [self createBtnsView];
}

- (void)createBtnsView
{
    //如果按钮个数小于1，那么不现实底部的切换按钮
    if ([_scanInfos count] <= 1)
        return;
    
    NSMutableArray *btns = [NSMutableArray arrayWithCapacity:[_scanInfos count]];
    for (NSDictionary *info in _scanInfos) {
        UIButton *btn = info[kScanButton];
        [self.view addSubview:btn];
        [btns addObject:btn];
    }
    
    //自动平分布局
    NSInteger padding = 10;
    [btns mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:padding leadSpacing:padding tailSpacing:padding];
    [btns mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-50*SCALE);
        make.height.mas_equalTo(72*SCALE);
    }];
    
    for (UIButton *btn in btns) {
        [self resetButton:btn];
    }
}

#pragma mark - Private Methods
-(void)shiftPlateReco
{
    [self.plateShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"plateIcon-pre"] forState:UIControlStateNormal];
    [self.vinShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"vinIcon"] forState:UIControlStateNormal];
    [self.qrShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"qrIcon"] forState:UIControlStateNormal];
}

-(void)shiftVinReco
{
    [self.vinShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"vinIcon-pre"] forState:UIControlStateNormal];
    [self.plateShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"plateIcon"] forState:UIControlStateNormal];
    [self.qrShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"qrIcon"] forState:UIControlStateNormal];
}

- (void)shiftQrReco
{
    [self.qrShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"qrIcon-pre"] forState:UIControlStateNormal];
    [self.plateShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"plateIcon"] forState:UIControlStateNormal];
    [self.vinShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"vinIcon"] forState:UIControlStateNormal];
}

-(UIButton *)plateShiftBtn
{
    if(!_plateShiftBtn)
    {
        _plateShiftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_plateShiftBtn setTitle:@"车牌号" forState:UIControlStateNormal];
        _plateShiftBtn.titleLabel.font = [UIFont systemFontOfSize:14*SCALE];
        [_plateShiftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_plateShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"plateIcon-pre"] forState:UIControlStateNormal];
        [_plateShiftBtn addTarget:self action:@selector(plateBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        //
        _plateShiftBtn.tag = UCAROCRType_PlateNum;
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
        [_vinShiftBtn addTarget:self action:@selector(vinBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //
        _vinShiftBtn.tag = UCAROCRType_VIN;
    }
    return _vinShiftBtn;
}

-(UIButton *)qrShiftBtn
{
    if(!_qrShiftBtn)
    {
        _qrShiftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_qrShiftBtn setTitle:@"二维码" forState:UIControlStateNormal];
        _qrShiftBtn.titleLabel.font = [UIFont systemFontOfSize:14*SCALE];
        [_qrShiftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_qrShiftBtn setImage:[UCAROCRPlatformContext imageNamed:@"qrIcon-pre"] forState:UIControlStateNormal];
        [_qrShiftBtn addTarget:self action:@selector(qrBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //
        _qrShiftBtn.tag = UCAROCRType_QRCode;
    }
    return _qrShiftBtn;
}


-(void)resetButton:(UIButton*)btn
{
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height ,-btn.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-20, 0.0,0.0, -btn.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
}

- (UIViewController *)getViewControllerWithTag:(NSUInteger)tag
{
    UIViewController *ctrl = nil;
    for (NSDictionary *info in _scanInfos) {
        UIButton *btn = info[kScanButton];
        if (btn.tag == tag) {
            ctrl = info[kScanViewController];
            break;
        }
    }
    return ctrl;
}

- (void)hasResultPop
{
    if (self.autoPopViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - InitScanInfos
- (void)initScanInfosWithTypes:(UCAROCRTypes)types
{
    _scanInfos = [NSMutableArray array];

    if (types & UCAROCRType_VIN) {//车架号
        [self initVinInfos];
    }
    
    if (types & UCAROCRType_PlateNum) {//车牌号
        [self initPlateInfos];
    }
    
    if (types & UCAROCRType_QRCode) {//二维码，条形码
        [self initQRInfos];
    }
    
    //初始化第一个选中的View
    [self initScanView];
}

- (void)initScanInfosWithKinds:(NSArray <NSNumber *> *)kinds
{
    _scanInfos = [NSMutableArray array];
    for (NSNumber *kind in kinds) {
        UCAROCRTypes type = [kind integerValue];
        switch (type) {
            case UCAROCRType_VIN:
                [self initVinInfos];
                break;
            case UCAROCRType_PlateNum:
                [self initPlateInfos];
                break;
            case UCAROCRType_QRCode:
                [self initQRInfos];
                break;
            default:
                break;
        }
    }
    
    //初始化第一个选中的View
    [self initScanView];
}

- (void)initQRInfos
{
    _qrScanCtrl = [[UCARQRCodeScanViewController alloc] init];
    _qrScanCtrl.delegate = self;
    _qrScanCtrl.shouldAnimationPop = NO;
    _qrScanCtrl.shouldAutoPop = NO;
    [_scanInfos addObject:@{kScanTypeName:@"二维码",kScanViewController:_qrScanCtrl,kScanButton:self.qrShiftBtn}];
}

- (void)initPlateInfos
{
    __weak typeof(self) weakSelf = self;
    if (! _ocrCtrl) {
        _ocrCtrl = [[UCARSmartOCRCameraViewController alloc] init];
    }
    [_scanInfos addObject:@{kScanTypeName:@"车牌号",kScanViewController:_ocrCtrl,kScanButton:self.plateShiftBtn}];
    
    _ocrCtrl.isHiddenToggleBtns = YES;
    _ocrCtrl.isDefaultPlatScan = YES;
    [_ocrCtrl setResultBlock:^(NSString *result,UIImage *resultImage) {
        NSLog(@"result==[%@]",result);
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ucarScanResult:image:ocrType:)]) {
            [weakSelf.delegate ucarScanResult:result image:resultImage ocrType:UCAROCRType_PlateNum];
            [weakSelf hasResultPop];
        }
    }];
}

- (void)initVinInfos
{
    __weak typeof(self) weakSelf = self;
    if (!_ocrCtrl) {
        _ocrCtrl = [[UCARSmartOCRCameraViewController alloc] init];
    }
    [_scanInfos addObject:@{kScanTypeName:@"车架号",kScanViewController:_ocrCtrl,kScanButton:self.vinShiftBtn}];
    
    _ocrCtrl.isHiddenToggleBtns = YES;
    _ocrCtrl.isDefaultPlatScan = NO;
    [_ocrCtrl setResultBlock:^(NSString *result,UIImage *resultImage) {
        NSLog(@"result==[%@]",result);
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ucarScanResult:image:ocrType:)]) {
            [weakSelf.delegate ucarScanResult:result image:resultImage ocrType:UCAROCRType_VIN];
            [weakSelf hasResultPop];
        }
    }];
}

- (void)initScanView
{
    //添加第一个页面到viewController中
    if ([_scanInfos count] > 0) {
        UIButton *btn = _scanInfos[0][kScanButton];
        switch (btn.tag) {
            case UCAROCRType_VIN:
                [self vinBtnAction:btn];
                break;
            case UCAROCRType_PlateNum:
                [self plateBtnAction:btn];
                break;
            case UCAROCRType_QRCode:
                [self qrBtnAction:btn];
                break;
            default:
                break;
        }
    }
}
#pragma mark - UIViewController addChildViewController
- (void)bringBtnsToFront
{
    for (NSDictionary *info in _scanInfos) {
        UIButton *btn = info[kScanButton];
        [self.view bringSubviewToFront:btn];
    }
}

- (void)addChildViewController:(UIViewController *)childController toView:(UIView *)view
{
    [self addChildViewController:childController];
    
    //viewWillAppear
    [childController beginAppearanceTransition:YES animated:YES];
    [view addSubview:childController.view];
    [childController endAppearanceTransition];
    
    [childController didMoveToParentViewController:self];
    
    [childController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_top);
        make.bottom.equalTo(view.mas_bottom);
        make.left.equalTo(view.mas_left);
        make.right.equalTo(view.mas_right);
    }];
    
    [self bringBtnsToFront];
    self.curViewController = childController;
}


- (void)changeControllerFromOldController:(UIViewController *)oldController toNewController:(UIViewController *)newController
{
    if (oldController == newController)
        return;
#if 1
    [self addChildViewController:newController toView:self.view];
    
    //移除oldController，但在removeFromParentViewController：方法前不会调用willMoveToParentViewController:nil 方法，所以需要显示调用
    [newController didMoveToParentViewController:self];
    [oldController willMoveToParentViewController:nil];
    
    //viewWillDisAppear
    [oldController beginAppearanceTransition:NO animated:YES];
    [oldController.view removeFromSuperview];
    [oldController endAppearanceTransition];
    
    [oldController removeFromParentViewController];
#endif
   
#if 0
    if (!oldController) {
        [self addChildViewController:newController toView:self.view];
        
        //移除oldController，但在removeFromParentViewController：方法前不会调用willMoveToParentViewController:nil 方法，所以需要显示调用
        [newController didMoveToParentViewController:self];
        [oldController willMoveToParentViewController:nil];
        
        //viewWillDisAppear
        [oldController beginAppearanceTransition:NO animated:YES];
        [oldController.view removeFromSuperview];
        [oldController endAppearanceTransition];
        
        [oldController removeFromParentViewController];
    }else {
        [self addChildViewController:newController toView:self.view];
        [oldController willMoveToParentViewController:nil];
        
        [self transitionFromViewController:oldController toViewController:newController duration:2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            //动画
        } completion:^(BOOL finished) {
            if (finished) {
                [newController didMoveToParentViewController:self];
                
                //viewWillDisAppear
                [oldController beginAppearanceTransition:NO animated:YES];
                [oldController.view removeFromSuperview];
                [oldController endAppearanceTransition];
                
                [oldController removeFromParentViewController];
                
                [self bringBtnsToFront];

            }else {
                self.curViewController = oldController;
            }
        }];
    }
#endif
}

#pragma mark - Actions
- (void)plateBtnAction:(id)sender
{
    _ocrCtrl.isDefaultPlatScan = YES;
    [self shiftPlateReco];
    UIButton *button = (UIButton *)sender;
    UIViewController *ctrl = [self getViewControllerWithTag:button.tag];
    [self changeControllerFromOldController:self.curViewController toNewController:ctrl];
}

- (void)vinBtnAction:(id)sender
{
    _ocrCtrl.isDefaultPlatScan = NO;
    [self shiftVinReco];
    UIButton *button = (UIButton *)sender;
    UIViewController *ctrl = [self getViewControllerWithTag:button.tag];
    [self changeControllerFromOldController:self.curViewController toNewController:ctrl];
}

- (void)qrBtnAction:(id)sender
{
    [self shiftQrReco];
    UIButton *button = (UIButton *)sender;
    UIViewController *ctrl = [self getViewControllerWithTag:button.tag];
    [self changeControllerFromOldController:self.curViewController toNewController:ctrl];
}

#pragma mark - Public Methods
- (instancetype)initWithOCRTypes:(UCAROCRTypes)types
{
    if (self = [super init]) {
        self.autoPopViewController = YES;
        
        [self initScanInfosWithTypes:types];
    }
    return self;
}

- (instancetype)initWithOCRKinds:(NSArray<NSNumber *> *)types
{
    if (self = [super init]) {
        self.autoPopViewController = YES;
        
        [self initScanInfosWithKinds:types];
    }
    return self;
}


#pragma mark - UCARQRCodeScanViewControllerDelegate
- (void)scanResult:(NSString *)scanResult
{
    NSLog(@"scanResult===[%@]",scanResult);
    if (self.delegate && [self.delegate respondsToSelector:@selector(ucarScanResult:image:ocrType:)]) {
        [self.delegate ucarScanResult:scanResult image:nil ocrType:UCAROCRType_QRCode];
        [self hasResultPop];
    }
}
- (void)scanNotfindQRCode
{
    NSLog(@"scanNotfindQRCode~~~~~");
}
@end
