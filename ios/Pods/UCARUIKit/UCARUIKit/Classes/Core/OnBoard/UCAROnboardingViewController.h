//
//  UCAROnboardingViewController.h
//  UCarDriver
//  引导页
//  Created by baotim on 16/9/7.
//  Copyright © 2016年 szzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCAROnboardingContentViewController.h"

@interface UCAROnboardingViewController : UIViewController

// Skipping
@property (nonatomic, assign) BOOL             allowSkipping;//是否显示跳过按钮
@property (nonatomic, strong) dispatch_block_t skipHandler;//跳过按钮回调
// Swiping
@property (nonatomic, assign) BOOL             swipingEnabled;//是否允许swip
// Page Control
@property (nonatomic, assign) BOOL             hidePageControl;//是否隐藏page control
@property (nonatomic, assign) BOOL             fadeSkipButtonOnLastPage;
// bounce
@property (nonatomic, assign) BOOL             enableBounce; //是否允许bounce, 默认NO
// 是否开启 最后一页左滑 跳过 功能
@property (nonatomic, assign) BOOL             isSwipeSkip;//是否允许swip

// Initializers
+ (instancetype)onboardWithBackgroundImage:(UIImage *)backgroundImage contents:(NSArray *)contents;
- (instancetype)initWithBackgroundImage:(UIImage *)backgroundImage contents:(NSArray *)contents;
+ (instancetype)onboardWithBackgroundVideoURL:(NSURL *)backgroundVideoURL contents:(NSArray *)contents;
- (instancetype)initWithBackgroundVideoURL:(NSURL *)backgroundVideoURL contents:(NSArray *)contents;

// Manually moving to next page
- (void)moveNextPage;

// Delegate methods for internal use.
- (void)setCurrentPage:(UCAROnboardingContentViewController *)currentPage;
- (void)setNextPage:(UCAROnboardingContentViewController *)nextPage;

@property (nonatomic, strong) UIColor *skipButtonBackgroundColor; //默认透明颜色
@property (nonatomic, strong) UIColor *skipButtonTextColor; //默认白色颜色
@property (nonatomic, assign) CGFloat skipButtonFontSize;   //默认14
@property (nonatomic, strong) UIImage *skipButtonBackgroundImage; //默认nil
@property (nonatomic, assign) CGSize  skipButtonSize; //skipt button 宽高
@property (nonatomic, assign) CGPoint skipButtonLTCornerPoint; //skipt button 左上角坐标
@property (nonatomic, assign) CGFloat pageControlBottomPadding; //page control距离底部距离

@end
