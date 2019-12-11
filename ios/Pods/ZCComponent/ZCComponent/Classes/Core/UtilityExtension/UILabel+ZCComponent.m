//
//  UILabel+UCARUIKit.m
//  Pods-ZCComponent_Example
//
//  Created by 郑熙 on 2019/4/25.
//

#import "UILabel+ZCComponent.h"
#import "NSString+ZCComponent.h"

@implementation UILabel (ZCComponent)

+ (UILabel * _Nonnull)labelWithText:(NSString *)text font:(NSInteger)font color:(UIColor *)color {
    
    return [UILabel labelWithFrame:CGRectZero text:text font:font color:color alignment:NSTextAlignmentLeft lines:0];
}

+ (UILabel * _Nonnull)labelWithFrame:(CGRect)frame text:(NSString *)text font:(NSInteger)font color:(UIColor *)color {
    
    return [UILabel labelWithFrame:frame text:text font:font color:color alignment:NSTextAlignmentLeft lines:0];
}

+ (UILabel * _Nonnull)labelWithFrame:(CGRect)frame text:(NSString * _Nullable)text font:(NSInteger)size color:(UIColor * _Nullable)color alignment:(NSTextAlignment)alignment lines:(NSInteger)lines {
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setFont:[UIFont systemFontOfSize:size]];
    [label setText:text];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:color];
    [label setTextAlignment:alignment];
    [label setNumberOfLines:lines];
    return label;
}

- (CGFloat)calculatedHeight {
    return [self.text heightForWidth:self.frame.size.width andFont:self.font];
}

- (void)setFont:(UIFont * _Nonnull)font fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(fromIndex, toIndex - fromIndex)];
    [self setAttributedText:attributedString];
}

@end
