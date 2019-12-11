//
//  UIButton+UCARUIKit.m
//  Masonry
//
//  Created by 郑熙 on 2019/4/28.
//

#import "UIButton+ZCComponent.h"
#import "UIImage+ZCComponent.h"
#import "UIColor+ZCComponent.h"

@implementation UIButton (ZCComponent)

+ (instancetype _Nonnull)buttonWithFrame:(CGRect)frame {
    return [UIButton buttonWithFrame:frame title:nil];
}

+ (instancetype _Nonnull)buttonWithFrame:(CGRect)frame title:(NSString * _Nullable)title {
    return [UIButton buttonWithFrame:frame title:title backgroundImage:nil highlightedBackgroundImage:nil];
}

+ (instancetype _Nonnull)buttonWithTitle:(NSString * _Nonnull)title color:(UIColor * _Nonnull)color {
    return [UIButton buttonWithFrame:CGRectZero title:title color:color];
}

+ (instancetype _Nonnull)buttonWithFrame:(CGRect)frame title:(NSString * _Nonnull)title color:(UIColor * _Nonnull)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return [UIButton buttonWithFrame:frame title:title backgroundImage:[UIImage imageWithColor:color] highlightedBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:components[0]-0.1 green:components[1]-0.1 blue:components[2]-0.1 alpha:1]]];
}

+ (instancetype _Nonnull)buttonWithFrame:(CGRect)frame title:(NSString * _Nullable)title backgroundImage:(UIImage * _Nullable)backgroundImage highlightedBackgroundImage:(UIImage * _Nullable)highlightedBackgroundImage {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    
    return button;
}

+ (instancetype _Nonnull)buttonWithFrame:(CGRect)frame image:(UIImage * _Nonnull)image highlightedImage:(UIImage * _Nullable)highlightedImage {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    
    return button;
}

@end
