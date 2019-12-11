//
//  UCARLiveAlertView.m
//  UCarLive
//
//  Created by 宣佚 on 2017/6/21.
//  Copyright © 2017年 UCarInc. All rights reserved.
//

#import "UCARLiveAlertView.h"
#import "UCARLive_Color.h"

@interface UCARLiveAlertView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, copy) UcarLiveConfirmBtnBlock clickBlock;

@end

@implementation UCARLiveAlertView

- (instancetype)initWithTitle:(NSString *)t_title message:(NSString *)t_message containerView:(UIView *)t_containerView btnBlock:(UcarLiveConfirmBtnBlock)t_block {
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if(self)
    {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        _containerView = t_containerView;
        _title = t_title;
        _message = t_message;
        _clickBlock = t_block;
        
        [self createSubViews];
    }
    return self;
}

- (UIView *)contentView {
    if(!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 10/3;
        _contentView.layer.masksToBounds = YES;
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:17*UCARLIVE_SCALE weight:UIFontWeightRegular];
        _titleLabel.textColor = UCARLIVE_UIColorFromRGB(0x404041);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.text = _title;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.numberOfLines = 0;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_message];
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc]init];
        paragraph.lineSpacing = 5*UCARLIVE_SCALE;
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        paragraph.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, _message.length)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15*UCARLIVE_SCALE] range:NSMakeRange(0, _message.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:UCARLIVE_UIColorFromRGB(0x808080) range:NSMakeRange(0, _message.length)];
        _messageLabel.attributedText = attributedString;
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _messageLabel;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.layer.cornerRadius = 10/3;
        _confirmBtn.layer.masksToBounds = YES;
        _confirmBtn.backgroundColor = UCARLIVE_UIColorFromRGB(0x3fb268);
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateSelected];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _confirmBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16*UCARLIVE_SCALE];
        [_confirmBtn addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

- (void)createSubViews {
    
    CGFloat topToTitle = 30 * UCARLIVE_SCALE;
    CGFloat titleHeight = 18 * UCARLIVE_SCALE;
    CGFloat titleToMessage = 15 * UCARLIVE_SCALE;
    CGFloat messageToBtn = 15 * UCARLIVE_SCALE;
    CGFloat btnHeight = 30 * UCARLIVE_SCALE;
    CGFloat btnToBottm = 20 * UCARLIVE_SCALE;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_message];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc]init];
    paragraph.lineSpacing = 5*UCARLIVE_SCALE;
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, _message.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15*UCARLIVE_SCALE] range:NSMakeRange(0, _message.length)];
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
    CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(((UCARLIVE_SCREEN_WIDTH-152)*UCARLIVE_SCALE), CGFLOAT_MAX) options:options context:nil];
    NSLog(@"messageHight size:%@", NSStringFromCGSize(rect.size));
    CGFloat messageHight = rect.size.height + 5;
    
    if ([self.message isEqualToString:@""] || self.message == nil) {
        messageHight = 0;
    }
    
    CGFloat contentHeight = topToTitle + titleHeight + titleToMessage + messageHight + messageToBtn + btnHeight + btnToBottm;
    
    [self addSubview:self.contentView];
    
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:self.contentView
                                  attribute:NSLayoutAttributeLeft
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                  attribute:NSLayoutAttributeLeft
                                 multiplier:1
                                   constant:(56 * UCARLIVE_SCALE)]];
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:self.contentView
                                  attribute:NSLayoutAttributeRight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                  attribute:NSLayoutAttributeRight
                                 multiplier:1
                                   constant:-(56 * UCARLIVE_SCALE)]];
    
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:self.contentView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1
                                   constant:contentHeight]];
    
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:self.contentView
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1
                                   constant:0]];
    
    
    [self.contentView addSubview:self.titleLabel];
    
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.titleLabel
                                  attribute:NSLayoutAttributeLeft
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeLeft
                                 multiplier:1
                                   constant:(20 * UCARLIVE_SCALE)]];
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.titleLabel
                                  attribute:NSLayoutAttributeRight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeRight
                                 multiplier:1
                                   constant:-(20 * UCARLIVE_SCALE)]];
    
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.titleLabel
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1
                                   constant:titleHeight]];
    
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:self.titleLabel
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeTop
                                 multiplier:1
                                   constant:topToTitle]];
    
    [self.contentView addSubview:self.confirmBtn];
    
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.confirmBtn
                                  attribute:NSLayoutAttributeLeft
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeLeft
                                 multiplier:1
                                   constant:(20 * UCARLIVE_SCALE)]];
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.confirmBtn
                                  attribute:NSLayoutAttributeRight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeRight
                                 multiplier:1
                                   constant:-(20 * UCARLIVE_SCALE)]];
    
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.confirmBtn
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1
                                   constant:btnHeight]];
    
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:self.confirmBtn
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1
                                   constant:-(btnToBottm)]];
    
    [self.contentView addSubview:self.messageLabel];
    
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.messageLabel
                                  attribute:NSLayoutAttributeLeft
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeLeft
                                 multiplier:1
                                   constant:(20 * UCARLIVE_SCALE)]];
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.messageLabel
                                  attribute:NSLayoutAttributeRight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeRight
                                 multiplier:1
                                   constant:-(20 * UCARLIVE_SCALE)]];
    
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.messageLabel
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.titleLabel
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1
                                   constant:titleToMessage]];
    
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.messageLabel
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1
                                   constant:messageHight]];
    
}

- (void)show {
    [self showWithAnimated:YES];
}

- (void)showWithAnimated:(BOOL)animation {
    
    [self.containerView addSubview:self];
    
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1.0;
            self.contentView.alpha = 1.0;
        }];
    } else {
        self.alpha = 1.0;
        self.contentView.alpha = 1.0;
    }
}

- (void)hideWithAnimated:(BOOL)animated
{
    if (animated) {
        //播放动画
        [UIView animateWithDuration:0.3 animations:^{
            self.contentView.alpha = 0.0;
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.contentView removeFromSuperview];
                [self removeFromSuperview];
            }
        }];
    } else {
        [self.contentView removeFromSuperview];
        [self removeFromSuperview];
    }
}

- (void)hideView {
    [self hideWithAnimated:YES];
    if (self.clickBlock) {
        self.clickBlock();
    }
}

@end
