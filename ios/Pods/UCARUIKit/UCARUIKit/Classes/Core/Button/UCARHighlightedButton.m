//
//  UCARHighlightedButton.m
//  UCar
//
//  Created by KouArlen on 15/6/12.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import "UCARHighlightedButton.h"
#import "UCARUIKitTools.h"

@interface UCARHighlightedButton ()

+ (instancetype)highlightedButton;

@end

@implementation UCARHighlightedButton


+ (instancetype)buttonWithStyle:(UCARHighlightedButtonStyle)style
{
    switch (style) {
        case UCARHighlightedButtonStyleGold:
            return [UCARGoldHighlightedButton buttonWithType:UIButtonTypeCustom];
            break;
        case UCARHighlightedButtonStyleNormal:
            return [UCARNormalHighlightedButton buttonWithType:UIButtonTypeCustom];
        default:
            break;
    }
}


#pragma mark -
#pragma mark - setter
- (void)setEnableColor:(UIColor *)enableColor {
    _enableColor = enableColor;
    [self resetStyle];
}

- (void)setDisableColor:(UIColor *)disableColor {
    _disableColor = disableColor;
    [self resetStyle];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;
    [self resetStyle];
}

- (void)setEnableTextColor:(UIColor *)enableTextColor {
    _enableTextColor = enableTextColor;
    [self resetStyle];
}

- (void)setDisableTextColor:(UIColor *)disableTextColor {
    _disableTextColor = disableTextColor;
    [self resetStyle];
}

- (void)setLabelFont:(UIFont *)labelFont {
    _labelFont = labelFont;
    [self resetStyle];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self resetStyle];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    [self resetStyle];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self resetStyle];
}

// 重置显示样式
- (void)resetStyle
{
    if (self.enabled) {
        if (self.highlighted) {
            if (self.highlightColor) {
                self.backgroundColor = self.highlightColor;
            }
        } else {
            if (self.enableColor) {
                self.backgroundColor = self.enableColor;
            }
        }
        if (self.enableTextColor) {
            [self setTitleColor:self.enableTextColor forState:UIControlStateNormal];
        }
    } else {
        if (self.disableColor) {
            self.backgroundColor = self.disableColor;
        }
        if (self.disableTextColor) {
            [self setTitleColor:self.disableTextColor forState:UIControlStateNormal];
        }
    }
    
    if (self.borderColor) {
        self.layer.cornerRadius = 3.0;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = self.borderColor.CGColor;
    }
    
    if (self.labelFont) {
        self.titleLabel.font = self.labelFont;
    } else {
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
    }
}

@end


@implementation UCARGoldHighlightedButton

+ (instancetype)highlightedButton
{
    UCARGoldHighlightedButton *button = [UCARGoldHighlightedButton buttonWithType:UIButtonTypeCustom];
    return button;
}

@end


@implementation UCARNormalHighlightedButton

+ (instancetype)highlightedButton
{
    UCARNormalHighlightedButton *button = [UCARNormalHighlightedButton buttonWithType:UIButtonTypeCustom];
    return button;
}

@end
