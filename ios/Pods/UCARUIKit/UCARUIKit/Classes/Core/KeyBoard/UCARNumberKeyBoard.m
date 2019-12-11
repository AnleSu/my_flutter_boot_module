//
//  UCARNumberKeyBoard.m
//  IdentityCardInput
//
//  Created by KouArlen on 15/7/16.
//  Copyright (c) 2015年 KouArlen. All rights reserved.
//

#import "UCARNumberKeyBoard.h"
#import "UCARUIKitTools.h"

#define iphoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ([[UIScreen mainScreen] currentMode].size.height == 2436) : NO)

#define BOTTOM_PADDING (iphoneX ? 34 : 0)

@interface UCARPayKeyButton : UIButton

@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *highlightedColor;

@end

@implementation UCARPayKeyButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _normalColor = nil;
        _highlightedColor = nil;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (self.enabled) {
        if (highlighted) {
            self.backgroundColor = _highlightedColor;
        } else {
            self.backgroundColor = _normalColor;
        }
    }
}

@end

@interface UCARNumberKeyBoard ()

@property (nonatomic, copy) NSAttributedString *title;

@end

@implementation UCARNumberKeyBoard

+ (UCARNumberKeyBoard *)keyBoard
{
    return [self keyBoardWithAttrTitle:nil];
}

+ (UCARNumberKeyBoard *)keyBoardWithTitle:(NSString *)title
{
    if (title) {
        NSDictionary *attrDict = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                   NSFontAttributeName : [UIFont systemFontOfSize:22]};
        NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:title attributes:attrDict];
        return [self keyBoardWithAttrTitle:attrTitle];
    } else {
        return [self keyBoardWithAttrTitle:nil];
    }
}

//自定义一个左下角字符
+ (UCARNumberKeyBoard *)keyBoardWithAttrTitle:(NSAttributedString *)title
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = width / 1.9 + BOTTOM_PADDING;
    UCARNumberKeyBoard *keyBoard = [[UCARNumberKeyBoard alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    keyBoard.title = title;
    
    return keyBoard;
}

- (void)setTitle:(NSAttributedString *)title
{
    _title = title;
    CGFloat padding = 0.5;
    CGFloat btnWidth = (self.frame.size.width-padding*2) / 3;
    CGFloat btnHeight = (self.frame.size.height-padding*5 - BOTTOM_PADDING) / 4;
    
    NSDictionary *attrDict = @{NSForegroundColorAttributeName : [UIColor blackColor],
                               NSFontAttributeName : [UIFont systemFontOfSize:22]};
    UIColor *normalColor = [UIColor whiteColor];
    UIColor *highlightedColor = UCAR_ColorFromHexString(@"#d1d5db");
    
    for (int i=0; i<4; i++) {
        for (int j=0; j<3; j++) {
            int number = i*3+j+1;
            UCARPayKeyButton *btn = [[UCARPayKeyButton alloc] initWithFrame:CGRectZero];
            if (number == 10) {
                btn.backgroundColor = highlightedColor;
                if (title) {
                    [btn setAttributedTitle:title forState:UIControlStateNormal];
                    btn.highlightedColor = normalColor;
                    btn.normalColor = highlightedColor;
                } else {
                    btn.enabled = NO;
                }
            } else if (number == 12) {
                btn.backgroundColor = highlightedColor;
                btn.normalColor = highlightedColor;
                btn.highlightedColor = normalColor;
                [btn setImage:[UIImage imageNamed:@"keyboard_delete"] forState:UIControlStateNormal];
                btn.adjustsImageWhenHighlighted = NO;
            } else {
                if (number == 11) {
                    number = 0;
                }
                NSString *btnTitle = [NSString stringWithFormat:@"%d", number];
                NSAttributedString *titleAttr = [[NSAttributedString alloc] initWithString:btnTitle attributes:attrDict];
                [btn setAttributedTitle:titleAttr forState:UIControlStateNormal];
                btn.backgroundColor = normalColor;
                btn.normalColor = normalColor;
                btn.highlightedColor = highlightedColor;
            }
            
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = number;
            btn.frame = CGRectMake((btnWidth+padding)*j, (btnHeight+padding)*i + padding, btnWidth, btnHeight);
            [self addSubview:btn];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UCAR_ColorFromHexString(@"#d1d5db");
        _inputTag = 0;
        _clickBlock = nil;
    }
    return self;
}

- (void)btnClicked:(UCARPayKeyButton *)sender
{
    switch (sender.tag) {
        case 10:
            if (_clickBlock) {
                _clickBlock(_title.string, UCARNumberKeyBoardClickTypeUserDefined, _inputTag);
            }
            break;
        case 12:
            if (_clickBlock) {
                _clickBlock(nil, UCARNumberKeyBoardClickTypeDelete, _inputTag);
            }
            break;
        default:
            if (_clickBlock) {
                _clickBlock(@(sender.tag).stringValue, UCARNumberKeyBoardClickTypeInput, _inputTag);
            }
            break;
    }
}

@end
