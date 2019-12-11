//
//  UCARHighlightedButton.h
//  UCar
//
//  Created by KouArlen on 15/6/12.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UCARHighlightedButtonStyle)
{
    //白底黑字
    UCARHighlightedButtonStyleNormal,
    //金底白字
    UCARHighlightedButtonStyleGold,
};

@interface UCARHighlightedButton : UIButton

@property (nonatomic, strong) UIColor *enableColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *disableColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *enableTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *disableTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIFont *labelFont UI_APPEARANCE_SELECTOR;


/**
 if you don't need border color, don't set this
 */
@property (nonatomic, strong) UIColor *borderColor UI_APPEARANCE_SELECTOR;

+ (instancetype)buttonWithStyle:(UCARHighlightedButtonStyle)style;

@end


@interface UCARGoldHighlightedButton : UCARHighlightedButton
@end

@interface UCARNormalHighlightedButton : UCARHighlightedButton
@end
