//
//  UCARAlertView.m
//  UCar
//
//  Created by KouArlen on 15/6/9.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import "UCARAlertView.h"
#import "UCARUIKitTools.h"
#import <Masonry/Masonry.h>
#import <CoreText/CoreText.h>
#import "UCARHighlightedButton.h"
#import "UCARUIKitConfigInstance.h"

@implementation UCARHighlightedAlertOKButton
@end
@implementation UCARHighlightedAlertCancelButton
@end

@interface UCARAlertButtonStackView: UIView

@property (nonatomic, assign) NSInteger stackCount;
@property (nonatomic, assign) BOOL hammerLayout;
@property (nonatomic, assign) CGFloat padding;

@end

@implementation UCARAlertButtonStackView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    NSArray *subviews = self.subviews;
    NSInteger count = subviews.count;
    if (count == 1) {
        UIView *subview = subviews[0];
        if (self.hammerLayout) {
            subview.frame = self.bounds;
        } else {
            subview.frame = CGRectMake(_padding, 0, width-_padding*2, height-10);
        }
        
    } else {
        CGFloat delta = 0;
        CGFloat space = 0;
        CGFloat padding = 0;
        CGFloat heightDelta = 0;
        if (!self.hammerLayout) {
            padding = _padding;
            space = 14;
            heightDelta = 10;
            delta = _padding * 2 + space;
        }
        CGFloat btnWidth = (width-delta) / subviews.count;
        for (NSInteger i= 0; i<count; i++) {
            UIView *subview = subviews[i];
            subview.frame = CGRectMake(padding + (btnWidth+space)*i, 0, btnWidth, height-heightDelta);
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    if (self.hammerLayout) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIGraphicsPushContext(context);
        
        UIColor *lineColor = UCAR_ColorFromHexString(@"#f0f0f0");
        CGFloat lineWidth = 1;
        
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
        UIBezierPath *anchorPath = [UIBezierPath bezierPath];
        [anchorPath moveToPoint:CGPointMake(0, 1)];
        [anchorPath addLineToPoint:CGPointMake(width, 1)];
        CGContextAddPath(context, anchorPath.CGPath);
        CGContextStrokePath(context);
        
        NSInteger count = self.stackCount;
        if (count > 0) {
            CGFloat gapWidth = width / count;
            for (NSInteger i=1; i<count; i++) {
                CGContextSetLineWidth(context, lineWidth);
                CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
                CGPoint lineTop = CGPointMake(gapWidth*i, 1);
                CGPoint lineBottom = CGPointMake(gapWidth*i, height);
                UIBezierPath *linePath = [UIBezierPath bezierPath];
                [linePath moveToPoint:lineTop];
                [linePath addLineToPoint:lineBottom];
                CGContextAddPath(context, linePath.CGPath);
                CGContextStrokePath(context);
            }
        }
    }
    
    
    [super drawRect:rect];
}

@end

@interface UCARAlertView ()

@property (nonatomic, assign) UCARAlertButtonLayoutStyle buttonLayoutStyle;

/**
 距离父view margin
 */
@property (nonatomic, assign) CGFloat margin;

/**
 内部布局 padding
 */
@property (nonatomic, assign) CGFloat padding;

@property (nonatomic, strong, nonnull) UIColor *titleColor;
@property (nonatomic, strong, nonnull) UIFont *titleFont;

@property (nonatomic, strong, nonnull) UIFont *noMessageTitleFont;

@property (nonatomic, strong, nonnull) UIColor *messageColor;
@property (nonatomic, strong, nonnull) UIFont *messageFont;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UCARHighlightedAlertCancelButton *cancelBtn;
@property (nonatomic, strong) UCARHighlightedAlertOKButton *OKBtn;
@property (nonatomic, strong, readwrite) UCARAlertButtonStackView *stackView;

@property (nonatomic, copy) UCARAlertClickedBlock clickBlock;

@property (nonatomic, assign) CGFloat contentWidth;
@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, strong) NSAttributedString *attrTitle;
@property (nonatomic, strong) NSAttributedString *attrMessage;

@end

@implementation UCARAlertView

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.numberOfLines = 0;
    }
    return _messageLabel;
}

- (UCARAlertButtonStackView *)stackView
{
    if (!_stackView) {
        _stackView = [[UCARAlertButtonStackView alloc] initWithFrame:CGRectZero];
        _stackView.backgroundColor = [UIColor whiteColor];
    }
    return _stackView;
}

- (UCARHighlightedAlertCancelButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [UCARHighlightedAlertCancelButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UCARHighlightedAlertOKButton *)OKBtn
{
    if (!_OKBtn) {
        _OKBtn = [UCARHighlightedAlertOKButton buttonWithType:UIButtonTypeCustom];
        [_OKBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _OKBtn;
}

- (void)setIsTitleMustCenter:(BOOL)isTitleMustCenter
{
    _isTitleMustCenter = isTitleMustCenter;
    //reset layout
    [self reLayout];
}

- (void)setIsMessageMustCenter:(BOOL)isMessageMustCenter
{
    _isMessageMustCenter = isMessageMustCenter;
    //reset layout
    [self reLayout];
}

- (instancetype)initWithTitle:(NSString *)title buttonTitles:(NSArray<NSString *> *)buttonTitles containerView:(UIView *)containerView clickBlock:(UCARAlertClickedBlock)clickBlock
{
    return [self initWithTitle:title message:nil buttonTitles:buttonTitles containerView:containerView clickBlock:clickBlock];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray<NSString *> *)buttonTitles containerView:(UIView *)containerView clickBlock:(UCARAlertClickedBlock)clickBlock
{
    UCARAlertView *alertView = [self initWithButtonTitles:buttonTitles containerView:containerView clickBlock:clickBlock];
    alertView.attrTitle = [self titleAttrStr:title message:message];
    alertView.attrMessage = [self messageAttrStr:message];
    [alertView reLayout];
    return alertView;
}

- (instancetype)initWithAttrTitle:(NSAttributedString *)title buttonTitles:(NSArray<NSString *> *)buttonTitles containerView:(UIView *)containerView clickBlock:(UCARAlertClickedBlock)clickBlock
{
    return [self initWithAttrTitle:title attrMessage:nil buttonTitles:buttonTitles containerView:containerView clickBlock:clickBlock];
}

- (instancetype)initWithAttrTitle:(NSAttributedString *)title attrMessage:(NSAttributedString *)message buttonTitles:(NSArray<NSString *> *)buttonTitles containerView:(UIView *)containerView clickBlock:(UCARAlertClickedBlock)clickBlock
{
    UCARAlertView *alertView = [self initWithButtonTitles:buttonTitles containerView:containerView clickBlock:clickBlock];
    alertView.attrTitle = title;
    alertView.attrMessage = message;
    [alertView reLayout];
    return alertView;
}

- (instancetype)initWithTitle:(NSString *)title attrMessage:(NSAttributedString *)message buttonTitles:(NSArray<NSString *> *)buttonTitles containerView:(UIView *)containerView clickBlock:(UCARAlertClickedBlock)clickBlock {
    UCARAlertView *alertView = [self initWithButtonTitles:buttonTitles containerView:containerView clickBlock:clickBlock];
    alertView.attrTitle = [self titleAttrStr:title message:message.string];;
    alertView.attrMessage = message;
    [alertView reLayout];
    return alertView;
}

- (instancetype)initWithButtonTitles:(NSArray<NSString *> *)buttonTitles containerView:(UIView *)containerView clickBlock:(UCARAlertClickedBlock)clickBlock
{
    self = [super initWithContainerView:containerView];
    if (self) {
        
        UCARAlertViewConfig *config = [UCARUIKitConfigInstance sharedConfig].alertViewConfig;
        
        _buttonLayoutStyle = config.buttonLayoutStyle;
        _isTitleMustCenter = config.isTitleMustCenter;
        _isMessageMustCenter = config.isMessageMustCenter;
        
        _margin = config.margin;
        _padding = config.padding;
        
        _titleColor = config.titleColor;
        _titleFont = config.titleFont;
        
        _noMessageTitleFont = config.noMessageTitleFont;
        
        _messageColor = config.messageColor;
        _messageFont = config.messageFont;
        
        _attrTitle = nil;
        _attrMessage = nil;
        
        
        self.clickBlock = clickBlock;
        
        self.animationType = UCARAnimationTypeAlpha;
        
        self.stackView.stackCount = buttonTitles.count;
        self.stackView.padding = _padding;
        self.stackView.hammerLayout = (_buttonLayoutStyle == UCARAlertButtonLayoutStyleHammer);
        if (buttonTitles.count > 1) {
            [self.cancelBtn setTitle:buttonTitles[0] forState:UIControlStateNormal];
            self.cancelBtn.tag = 0;
            [self.stackView addSubview:self.cancelBtn];
            [self.OKBtn setTitle:buttonTitles[1] forState:UIControlStateNormal];
            self.OKBtn.tag = 1;
            [self.stackView addSubview:self.OKBtn];
        } else {
            [self.OKBtn setTitle:buttonTitles[0] forState:UIControlStateNormal];
            self.OKBtn.tag = 0;
            [self.stackView addSubview:self.OKBtn];
        }
        
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.messageLabel];
        [self.contentView addSubview:self.stackView];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 6;
        self.contentView.layer.masksToBounds = YES;
    }
    return self;
}

//  居中显示样式
+ (instancetype)middleWithMessage:(NSString *)message buttonTitles:(NSArray<NSString *> *)buttonTitles clickBlock:(UCARAlertClickedBlock)clickBlock {
    
    // 全局配置
    UCARAlertViewConfig *config = [UCARUIKitConfigInstance sharedConfig].alertViewConfig;
    
    // 属性字符, 需要将 message 的颜色与字体给 title
    NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:message];
    [attrMessage addAttribute:NSForegroundColorAttributeName value:config.messageColor range:NSMakeRange(0, attrMessage.length)];
    [attrMessage addAttribute:NSFontAttributeName value:config.messageFont range:NSMakeRange(0, attrMessage.length)];
    
    // 最顶层的 window
    UIWindow *frontWindow = [UIApplication sharedApplication].keyWindow;
    
    // 弹框
    return [[UCARAlertView alloc] initWithAttrTitle:attrMessage buttonTitles:buttonTitles containerView:frontWindow clickBlock:clickBlock];
}

- (void)buttonClicked:(UIButton *)sender
{
    if (self.clickBlock) {
        NSInteger index = sender.tag;
        self.clickBlock(index);
    }
    [self hide];
}

- (void)reLayout
{
    self.titleLabel.attributedText = _attrTitle;
    self.messageLabel.attributedText = _attrMessage;
    
    CGFloat containerWidth = self.containerView.bounds.size.width;
    CGFloat containerHeight = self.containerView.bounds.size.height;
    
    CGFloat contentWidth = containerWidth - self.margin*2;
    CGFloat labelWidth = contentWidth - self.padding*2;
    
    CGFloat topOffset = 20;
    CGFloat titleHeight = [self heightForAttrString:_attrTitle boundsWidth:labelWidth];
    self.titleLabel.frame = CGRectMake(self.padding, topOffset, labelWidth, titleHeight);
    topOffset += titleHeight + 10;
    if (self.isTitleMustCenter)
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    else
    {
        if (titleHeight > self.titleLabel.font.pointSize*2) {
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
        } else {
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    CGFloat messageHeight = [self heightForAttrString:_attrMessage boundsWidth:labelWidth];
    self.messageLabel.frame = CGRectMake(self.padding, topOffset, labelWidth, messageHeight);
    // 这里主要是修复仅有 title 提示的时候, 让提示的内容保证上下居中
    if (messageHeight == 0) {
        topOffset += messageHeight + 10;
    } else {
        topOffset += messageHeight + 16;
    }
    if (self.isMessageMustCenter) {
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
    } else if (messageHeight > self.messageLabel.font.pointSize*2) {
        self.messageLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    self.stackView.frame = CGRectMake(0, topOffset, contentWidth, 50);
    
    
    CGFloat contentHeight = topOffset + 50;
    CGFloat topMargin = (containerHeight-contentHeight)/2;
    self.contentView.frame = CGRectMake(self.margin, topMargin, contentWidth, contentHeight);
}

- (NSAttributedString *)titleAttrStr:(NSString *)title message:(NSString *)message
{
    if (!title) {
        return nil;
    }
    UIFont *font = self.noMessageTitleFont;
    if (message) {
        font = self.titleFont;
    }
    NSAttributedString *textAttr = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: self.titleColor}];
    return textAttr;
}

- (NSAttributedString *)messageAttrStr:(NSString *)message
{
    if (!message) {
        return nil;
    }
    NSAttributedString *textAttr = [[NSAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName: self.messageFont, NSForegroundColorAttributeName: self.messageColor}];
    return textAttr;
}

- (CGFloat)heightForAttrString:(NSAttributedString *)attrStr boundsWidth:(CGFloat)width
{
    if (!attrStr) {
        return 0;
    }
    CGSize labelSize = [attrStr boundingRectWithSize:CGSizeMake(width, 2000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return labelSize.height + 2;
}

// 设置按钮字体大小
- (void)setupButtonFont:(UIFont*)buttonFont {
    if (buttonFont) {
        _cancelBtn.labelFont = buttonFont;
        _OKBtn.labelFont = buttonFont;
    }
}

@end
