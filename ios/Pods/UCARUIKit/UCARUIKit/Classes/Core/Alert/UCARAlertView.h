//
//  UCARAlertView.h
//  UCar
//
//  Created by KouArlen on 15/6/9.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import "UCARAnimationView.h"
#import "UCARHighlightedButton.h"

@interface UCARHighlightedAlertOKButton: UCARHighlightedButton
@end
@interface UCARHighlightedAlertCancelButton: UCARHighlightedButton
@end

typedef void(^UCARAlertClickedBlock)(NSInteger index);

//don't call [self.view addSubview:view]

@interface UCARAlertView : UCARAnimationView

@property (nonatomic, assign) BOOL isTitleMustCenter;
@property (nonatomic, assign) BOOL isMessageMustCenter;

// 专车中弹框倒计时用到 messageLabel & clickBlock
@property (nonatomic, strong, readonly) UILabel *messageLabel;
@property (nonatomic, copy, readonly) UCARAlertClickedBlock clickBlock;

- (nullable instancetype)initWithTitle:(nonnull NSString *)title buttonTitles:(nonnull NSArray<NSString *> *)buttonTitles containerView:(nonnull UIView *)containerView clickBlock:(nonnull UCARAlertClickedBlock)clickBlock;

- (nullable instancetype)initWithTitle:(nonnull NSString *)title message:(nullable NSString *)message buttonTitles:(nonnull NSArray<NSString *> *)buttonTitles containerView:(nonnull UIView *)containerView clickBlock:(nonnull UCARAlertClickedBlock)clickBlock;

- (nullable instancetype)initWithAttrTitle:(nonnull NSAttributedString *)title buttonTitles:(nonnull NSArray<NSString *> *)buttonTitles containerView:(nonnull UIView *)containerView clickBlock:(nonnull UCARAlertClickedBlock)clickBlock;

- (nullable instancetype)initWithAttrTitle:(nonnull NSAttributedString *)title attrMessage:(nullable NSAttributedString *)message buttonTitles:(nonnull NSArray<NSString *> *)buttonTitles containerView:(nonnull UIView *)containerView clickBlock:(nonnull UCARAlertClickedBlock)clickBlock;

// 专车中用到
- (instancetype)initWithTitle:(NSString *)title attrMessage:(NSAttributedString *)message buttonTitles:(NSArray<NSString *> *)buttonTitles containerView:(UIView *)containerView clickBlock:(UCARAlertClickedBlock)clickBlock;


/**
 居中显示样式

 @param message 显示的居中消息
 @param buttonTitles a按钮集合
 @param clickBlock 点击事件
 */
+ (instancetype)middleWithMessage:(NSString *)message
                     buttonTitles:(NSArray<NSString *> *)buttonTitles
                       clickBlock:(UCARAlertClickedBlock)clickBlock;

/**
 设置按钮字体大小, 有值则直接设置, 没有值(nil)则使用全局设置的值
 
 @note 用于按钮的文案较长, 临时调整按钮字体大小
 */
- (void)setupButtonFont:(UIFont*)buttonFont;

/** 布局
 @note 非继承, 不调用 (专车中弹框倒计时用到)
 */
- (void)reLayout;

@end
