//
//  UCarSmaertOCRResultViewController.m
//  CMTPlatform
//
//  Created by ZhangYuqing on 2019/4/23.
//  Copyright © 2019 UCAR. All rights reserved.
//

#import "UCarSmartOCRResultViewController.h"
#import <Masonry/Masonry.h>
#import "OCRMacroColor.h"
#import "OCRMacroUI.h"
#import "UIView+OCRToast.h"
#import "UCAROCRPlatformContext.h"
#import "OCRMacroColor.h"

@interface UCarSmartOCRResultViewController ()
@property (strong,nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UITextField *textField;
@property (strong,nonatomic) UIView *bottomView;
@property (strong,nonatomic) UIButton * bottomCopyButton;
@property (strong,nonatomic) UIButton * searchButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *backBtn;
@property (strong,nonatomic) UILabel *leftBottomButtonLabel;
@property (strong,nonatomic) UILabel *rightBottomButtonLabel;
@end

@implementation UCarSmartOCRResultViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self createUI];
    [self hasNoZCAccess];
    if (self.hasSearchAccess)
    {
        [self hasZCAccess];
    }
}

#pragma mark - getter
    
-(UILabel *)titleLabel
{
    if(!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = @"确认识别信息";
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

- (void)createUI
{
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
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    finishButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [finishButton addTarget:self action:@selector(finishButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishButton];
    [finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(-20*SCALE);
        make.width.mas_equalTo(45*SCALE);
        make.height.mas_equalTo(35*SCALE);
    }];
    
    NSLog(@"image is: %@",self.resultImage);
    self.imageView = [[UIImageView alloc]init];
    self.imageView.layer.borderWidth = 2.0f;
    self.imageView.layer.borderColor = [UIColor redColor].CGColor;
    [self.view addSubview:self.imageView];
    self.imageView.image = self.resultImage;
    
    self.textField = [[UITextField alloc]init];
    self.textField.text = self.resultString;
    self.textField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.textField];
    
    self.textField.font = [UIFont boldSystemFontOfSize:20.0f];
    self.textField.textColor = UIColorFromRGB(0x666666);
    self.textField.backgroundColor = [UIColor whiteColor];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.textField.mas_top).offset(-10);
        make.width.mas_equalTo(268);
    }];
    
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(268);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(55);
    }];
    
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.backgroundColor = UIColorFromRGB(0x464646);
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
    promptLabel.textColor = [UIColor whiteColor];
    promptLabel.text = @"请核对识别信息，如有错误，点击修改";
    promptLabel.layer.cornerRadius = 15.0f;
    promptLabel.clipsToBounds = YES;
    [self.view addSubview:promptLabel];
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(self.textField.mas_width);
        make.height.mas_equalTo(30);
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10);
    }];
    
    self.bottomView = [[UIView alloc]init];
    [self.view addSubview:self.bottomView];
    self.bottomView.backgroundColor = [UIColor blackColor];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(130);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            // Fallback on earlier versions
            make.bottom.mas_equalTo(self.view.mas_bottom);
        }
    }];
    
    UIButton *copyButton = [self createButtonWithImage:@"qrCopyButtonImage" target:@selector(copyButtonDidClick) title:@"复制" hightLightedImage:@"qrCopyButtonHighlighted"];
    [self.bottomView addSubview:copyButton];
    UIButton *searchButton = [self createButtonWithImage:@"qrSearchButtonImage" target:@selector(searchButtonDidClick) title:@"搜任务" hightLightedImage:@"qrSearchButtonHighlighted"];
    [self.bottomView addSubview:searchButton];
    
    [copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bottomView.mas_left).offset(100);
        make.centerY.mas_equalTo(0);
    }];
    
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bottomView.mas_right).offset(-100);
        make.centerY.mas_equalTo(0);
    }];

    self.bottomCopyButton = copyButton;
    self.searchButton = searchButton;
    
    self.leftBottomButtonLabel = [[UILabel alloc]init];
    self.leftBottomButtonLabel.textAlignment = NSTextAlignmentCenter;
    [self.leftBottomButtonLabel sizeToFit];
    self.leftBottomButtonLabel.textColor = [UIColor whiteColor];
    self.leftBottomButtonLabel.font = [UIFont systemFontOfSize:14*SCALE];
    self.leftBottomButtonLabel.text = @"复制";
    
    self.rightBottomButtonLabel = [[UILabel alloc]init];
    self.rightBottomButtonLabel.textAlignment = NSTextAlignmentCenter;
    [self.rightBottomButtonLabel sizeToFit];
    self.rightBottomButtonLabel.textColor = [UIColor whiteColor];
    self.rightBottomButtonLabel.font = [UIFont systemFontOfSize:14*SCALE];
    self.rightBottomButtonLabel.text = @"搜任务";
    
    [self.bottomView addSubview:self.leftBottomButtonLabel];
    [self.bottomView addSubview:self.rightBottomButtonLabel];
    
    [self.leftBottomButtonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bottomCopyButton.mas_centerX);
        make.top.mas_equalTo(self.bottomCopyButton.mas_bottom).offset(0);
    }];
    
    [self.rightBottomButtonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.searchButton.mas_centerX);
        make.top.mas_equalTo(self.searchButton.mas_bottom).offset(0);
    }];
    
}


- (UIButton *)createButtonWithImage:(NSString *)imageName target:(SEL)selector title:(NSString *)title hightLightedImage:(NSString *)hightLightedImage
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UCAROCRPlatformContext imageNamed:imageName];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setImage:[UCAROCRPlatformContext imageNamed:hightLightedImage] forState:UIControlStateHighlighted];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)copyButtonDidClick
{
    if (self.textField.text.length > 0)
    {
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = self.textField.text;
        [self.view ocr_makeToast:@"已复制"];
    }
}

- (void)searchButtonDidClick
{
    [self showScanSearchVC];
}

- (void)finishButtonDidClick
{
    [self.textField endEditing:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)hasNoZCAccess
{
    self.searchButton.hidden = YES;
    self.rightBottomButtonLabel.hidden = YES;
    [self.bottomCopyButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
    }];
}


- (void)hasZCAccess
{
    self.searchButton.hidden = NO;
    self.rightBottomButtonLabel.hidden = NO;
    [self.bottomCopyButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bottomView.mas_left).offset(100 * SCALE);
        make.centerY.mas_equalTo(0);
    }];
    
    [self.searchButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bottomView.mas_right).offset(-100 * SCALE);
        make.centerY.mas_equalTo(0);
    }];
}

    
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ZCScanViewControllerPopToSelfShouldToRestoreScan" object:nil];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
    
    
- (void)showScanSearchVC
{
    NSString *searchText = self.textField.text;
    UINavigationController *nav = self.navigationController;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"3DTouchPushSearchVC" object:nil userInfo:@{@"searchText":searchText,@"nav":nav}];
}
@end
