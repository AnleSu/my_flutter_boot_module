//
//  UCARAnimationView.m
//  UCARUIKit
//
//  Created by linux on 02/02/2018.
//

#import "UCARAnimationView.h"

const NSTimeInterval UCARAnimationDuration = 0.3;

@interface UCARAnimationView ()
@property (nonatomic, strong, readwrite) UIButton *backView;
@property (nonatomic, strong, readwrite) UIView *contentView;
@end

@implementation UCARAnimationView

- (UIButton *)backView
{
    if (!_backView) {
        _backView = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _backView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _contentView;
}

- (instancetype)initWithContainerView:(UIView *)containerView
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.containerView = containerView;
        self.animationType = UCARAnimationTypeNone;
        
        self.frame = containerView.bounds;
        self.backView.frame = containerView.bounds;
        [self addSubview:self.backView];
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)show
{
    [self.containerView addSubview:self];
    
    switch (self.animationType) {
        case UCARAnimationTypeNone:
            break;
        case UCARAnimationTypeAlpha:
            [self alphaShow];
            break;
        case UCARAnimationTypeMoveFromTop:
            [self topShow];
            break;
        case UCARAnimationTypeMoveFromBottom:
            [self bottomShow];
            break;
            
        default:
            break;
    }
}

- (void)hide
{
    if (self.foreverExist) {
        // 点击按钮不消失
        return;
    }
    
    switch (self.animationType) {
        case UCARAnimationTypeNone:
            [self removeFromSuperview];
            break;
        case UCARAnimationTypeAlpha:
            [self alphaHide];
            break;
        case UCARAnimationTypeMoveFromTop:
            [self topHide];
            break;
        case UCARAnimationTypeMoveFromBottom:
            [self bottomHide];
            break;
        default:
            break;
    }
}

- (void)alphaShow
{
    self.alpha = 0.0;
    [UIView animateWithDuration:UCARAnimationDuration animations:^{
        self.alpha = 1.0;
    }];
}

- (void)alphaHide
{
    [UIView animateWithDuration:UCARAnimationDuration animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)bottomShow
{
    self.alpha = 0.0;
    [UIView animateWithDuration:UCARAnimationDuration animations:^{
        self.alpha = 1.0;
    }];
}
- (void)bottomHide
{
    [UIView animateWithDuration:UCARAnimationDuration animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)topShow
{
    self.alpha = 0.0;
    [UIView animateWithDuration:UCARAnimationDuration animations:^{
        self.alpha = 1.0;
    }];
}

- (void)topHide
{
    [UIView animateWithDuration:UCARAnimationDuration animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark -
#pragma mark - setter
- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor;
    self.backView.backgroundColor = backColor;
}

- (void)remakeConstraints
{
}

- (void)updateConstraints
{
    [self remakeConstraints];
    [super updateConstraints];
}

@end
