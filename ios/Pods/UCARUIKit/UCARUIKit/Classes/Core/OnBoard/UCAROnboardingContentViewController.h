//
//  UCAROnboardingContentViewController.h
//  UCarDriver
//
//  Created by baotim on 16/9/7.
//  Copyright © 2016年 szzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCAROnboardingViewController;

@interface UCAROnboardingContentViewController : UIViewController

@property (nonatomic, weak  ) UCAROnboardingViewController* delegate;

@property (nonatomic, strong) UIColor *actionButtonTextColor; //默认透明颜色
@property (nonatomic, assign) CGFloat actionButtonFontSize;   //默认14
@property (nonatomic, strong) UIImage *actionButtonBackgroundImage; //默认nil
@property (nonatomic, assign) CGSize  actionButtonSize; //action button 宽高
@property (nonatomic, assign) CGPoint actionButtonLTCornerPoint; //action button 左上角坐标
@property (nonatomic, strong) NSURL   *videoURL;

// Initializes
+ (instancetype)contentWithImage:(UIImage *)image buttonText:(NSString *)buttonText action:(dispatch_block_t)action;
- (instancetype)initWithImage:(UIImage *)image buttonText:(NSString *)buttonText action:(dispatch_block_t)action;
+ (instancetype)contentWithVideoURL:(NSURL *)videoURL buttonText:(NSString *)buttonText action:(dispatch_block_t)action;
- (instancetype)initWithVideoURL:(NSURL *)videoURL buttonText:(NSString *)buttonText action:(dispatch_block_t)action;
- (instancetype)initWithImage:(UIImage *)image videoURL:videoURL buttonText:(NSString *)buttonText action:(dispatch_block_t)action;

- (void)updateAlphas:(CGFloat)newAlpha;
- (void)stopVideoPlay;
- (void)handleButtonPressed;

@end
