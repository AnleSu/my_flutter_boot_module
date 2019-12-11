//
//  UIButton+UCARUIKit.h
//  Masonry
//
//  Created by 郑熙 on 2019/4/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (ZCComponent)

/**
 *  实例化button
 *
 *  @param frame Button's frame
 *
 *  @return Returns the UIButton instance
 */
+ (instancetype _Nonnull)buttonWithFrame:(CGRect)frame;

/**
 *  实例化button
 *
 *  @param frame Button's frame
 *  @param title Button's title, the title color will be white
 *
 *  @return Returns the UIButton instance
 */
+ (instancetype _Nonnull)buttonWithFrame:(CGRect)frame title:(NSString * _Nullable)title;

/**
 *  实例化button
 *
 *  @param title Button's title, the title color will be white
 *  @param color Button's color
 *
 *  @return Returns the UIButton instance
 */
+ (instancetype _Nonnull)buttonWithTitle:(NSString * _Nonnull)title color:(UIColor * _Nonnull)color;

/**
 *  实例化button
 *
 *  @param frame  Button's frame
 *  @param title  Button's title
 *  @param color  Button's color
 *
 *  @return Returns the UIButton instance
 */
+ (instancetype _Nonnull)buttonWithFrame:(CGRect)frame title:(NSString * _Nonnull)title color:(UIColor * _Nonnull)color;

/**
 *  实例化button
 *
 *  @param frame                      Button's frame
 *  @param title                      Button's title
 *  @param backgroundImage            Button's background image
 *  @param highlightedBackgroundImage Button's highlighted background image
 *
 *  @return Returns the UIButton instance
 */
+ (instancetype _Nonnull)buttonWithFrame:(CGRect)frame title:(NSString * _Nullable)title backgroundImage:(UIImage * _Nullable)backgroundImage highlightedBackgroundImage:(UIImage * _Nullable)highlightedBackgroundImage;

/**
 *  实例化button
 *
 *  @param frame            Button's frame
 *  @param image            Button's image
 *  @param highlightedImage Button's highlighted image
 *
 *  @return Returns the UIButton instance
 */
+ (instancetype _Nonnull)buttonWithFrame:(CGRect)frame image:(UIImage * _Nonnull)image highlightedImage:(UIImage * _Nullable)highlightedImage;

@end

NS_ASSUME_NONNULL_END
