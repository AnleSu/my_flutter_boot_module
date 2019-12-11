//
//  UCARAnimationView.h
//  UCARUIKit
//
//  Created by linux on 02/02/2018.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UCARAnimationType) {
    UCARAnimationTypeNone,
    UCARAnimationTypeAlpha,
    UCARAnimationTypeMoveFromBottom,
    UCARAnimationTypeMoveFromTop,
};

@interface UCARAnimationView: UIView

@property (nonatomic, strong, readonly, nonnull) UIButton *backView;
@property (nonatomic, weak, nullable) UIView *containerView;
@property (nonatomic, strong, readonly, nonnull) UIView *contentView;
@property (nonatomic, assign) UCARAnimationType animationType;

@property (nonatomic, strong, nonnull) UIColor *backColor UI_APPEARANCE_SELECTOR;

/** 是否永远存在
 
 @note 暂时在司机端使用
 
 YES: 点击 按钮不消失
 NO: 点击按钮 消失 (默认值)
 */
@property (nonatomic, assign) BOOL foreverExist;

- (nullable instancetype)initWithContainerView:(nonnull UIView *)containerView;

- (void)show;
- (void)hide;

- (void)remakeConstraints;

@end
