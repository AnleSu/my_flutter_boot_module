//
//  UIColor+UCARUIKit.h
//  Masonry
//
//  Created by 郑熙 on 2019/4/27.
//

@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/**
 *  快捷构造器
 *
 *  @param r Red value
 *  @param g Green value
 *  @param b Blue value
 *  @param a Alpha value
 *
 *  @return Returns the created UIColor
 */
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

/**
 *  快捷构造器
 *
 *  @param r Red value
 *  @param g Green value
 *  @param b Blue value
 *
 *  @return Returns the created UIColor
 */
#define RGB(r, g, b) RGBA(r, g, b, 1.0f)

@interface UIColor (ZCComponent)

/**
 *  RGB properties: red
 */
@property (nonatomic, readonly) CGFloat red;
/**
 *  RGB properties: green
 */
@property (nonatomic, readonly) CGFloat green;
/**
 *  RGB properties: blue
 */
@property (nonatomic, readonly) CGFloat blue;

/**
 *  从hex字符串构建UIColor.
 *  支持类型:
 *  - #RGB
 *  - #ARGB
 *  - #RRGGBB
 *  - #AARRGGBB
 *
 *  @param hexString HEX 字符串
 *
 *  @return Returns the UIColor instance
 */
+ (UIColor * _Nonnull)hex:(NSString * _Nonnull)hexString;

/**
 *  同上，方法名多加个string
 *
 *  @param hexString HEX 字符串
 *
 *  @return Returns the UIColor instance
 */
+ (UIColor * _Nonnull)hexString:(NSString * _Nonnull)hexString;

/**
 *  输入的hex值为int类型
 *
 *  @param hex HEX值
 *
 *  @return Returns the UIColor instance
 */
+ (UIColor * _Nonnull)colorWithHex:(unsigned int)hex;

/**
 *  随机颜色
 *
 *  @return Returns the UIColor instance
 */
+ (UIColor * _Nonnull)randomColor;

/**
 *  改变颜色的透明度，颜色空间和组成不变
 *
 *  @param color UIColor value
 *  @param alpha Alpha value
 *
 *  @return Returns the UIColor instance
 */
+ (UIColor * _Nonnull)colorWithColor:(UIColor * _Nonnull)color
                               alpha:(float)alpha;


@end

NS_ASSUME_NONNULL_END
