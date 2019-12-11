//
//  ZCCommonCarFlagView.h
//  ZCBusiness
//
//  Created by ZhangYuqing on 2019/3/2.
//  Copyright © 2019 UCAR. All rights reserved.
//

// import分组次序：Frameworks、Services、UI
#import <UIKit/UIKit.h>

#pragma mark - @class

#pragma mark - 常量

#pragma mark - 枚举

NS_ASSUME_NONNULL_BEGIN

/**
 * 通用的车辆标记FlagView
 * @note 通用的车辆标记FlagView
 */
@interface ZCCommonCarFlagView : UIView
/**
 设置文本数据
 @param flag1 第一个标记的文本
 @param flag2 第二个标记的文本数据
 */
- (void)setFlag1:(NSString *)flag1 flag2:(NSString *)flag2;
/**
 左侧View的文字颜色和边框颜色
 @param textColor 文字颜色
 @param cornerColor 边框颜色
 */
- (void)setLeftTextColor:(UIColor *)textColor cornerColor:(UIColor *)cornerColor;
/**
 右侧View的文字颜色和边框颜色
 @param textColor 文字颜色
 @param cornerColor 边框颜色
 */
- (void)setRightTextColor:(UIColor *)textColor cornerColor:(UIColor *)cornerColor;
@end

NS_ASSUME_NONNULL_END
