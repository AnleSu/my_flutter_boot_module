//
//  UILabel+UCARUIKit.h
//  Pods-ZCComponent_Example
//
//  Created by 郑熙 on 2019/4/25.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (ZCComponent)

/**
 *  类方法快速构建UILabel
 *
 *  @param text      Label's text
 *  @param font      Label's font size
 *  @param color     Label's text color
 *
 *  @return Returns the created UILabel
 */

+ (UILabel * _Nonnull)labelWithText:(NSString *)text font:(NSInteger)font color:(UIColor *)color;

/**
 *  类方法快速构建UILabel
 *
 *  @param frame     Label's frame
 *  @param text      Label's text
 *  @param font      Label's font size
 *  @param color     Label's text color
 *
 *  @return Returns the created UILabel
 */

+ (UILabel * _Nonnull)labelWithFrame:(CGRect)frame text:(NSString *)text font:(NSInteger)font color:(UIColor *)color;

/**
 *  类方法快速构建UILabel
 *
 *  @param frame     Label's frame
 *  @param text      Label's text
 *  @param font      Label's font size
 *  @param color     Label's text color
 *  @param alignment Label's text alignment
 *  @param lines     Label's text lines
 *
 *  @return Returns the created UILabel
 */
+ (UILabel * _Nonnull)labelWithFrame:(CGRect)frame text:(NSString * _Nullable)text font:(NSInteger)font color:(UIColor * _Nullable)color alignment:(NSTextAlignment)alignment lines:(NSInteger)lines;

/**
 *  Calculates height based on text, width and font
 *
 *  @return Returns calculated height
 */
- (CGFloat)calculatedHeight;

/**
 *  自定义Label fromIdex 到 toIndex之间的文字大小
 *
 *  @param font      New font to be setted
 *  @param fromIndex The start index
 *  @param toIndex   The end index
 */
- (void)setFont:(UIFont * _Nonnull)font
      fromIndex:(NSInteger)fromIndex
        toIndex:(NSInteger)toIndex;

@end

NS_ASSUME_NONNULL_END
