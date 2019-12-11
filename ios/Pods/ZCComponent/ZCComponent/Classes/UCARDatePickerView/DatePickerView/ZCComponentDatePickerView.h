//
//  UCARDatePickerView.h
//  UCARPickerViewDemo
//
//  Created by szq on 2019/4/25.
//  Copyright © 2019年 ucar. All rights reserved.//

#import "ZCComponentDatePickerBaseView.h"
#import "NSDate+ZCComponentDatePickerView.h"

/// 弹出日期类型
typedef NS_ENUM(NSInteger, UCARDatePickerMode) {
    // --- 以下4种是系统自带的样式 ---
    // UIDatePickerModeTime
    UCARDatePickerModeTime,              // HH:mm
    // UIDatePickerModeDate
    UCARDatePickerModeDate,              // yyyy-MM-dd
    // UIDatePickerModeDateAndTime
    UCARDatePickerModeDateAndTime,       // yyyy-MM-dd HH:mm
    // UIDatePickerModeCountDownTimer
    UCARDatePickerModeCountDownTimer,    // HH:mm
    // --- 以下7种是自定义样式 ---
    // 年月日时分
    UCARDatePickerModeYMDHM,      // yyyy-MM-dd HH:mm
    // 月日时分
    UCARDatePickerModeMDHM,       // MM-dd HH:mm
    // 年月日
    UCARDatePickerModeYMD,        // yyyy-MM-dd
    // 年月
    UCARDatePickerModeYM,         // yyyy-MM
    // 年
    UCARDatePickerModeY,          // yyyy
    // 月日
    UCARDatePickerModeMD,         // MM-dd
    // 时分
    UCARDatePickerModeHM          // HH:mm
};

typedef void(^UCARDateResultBlock)(NSString *selectValue);
typedef void(^UCARDateCancelBlock)(void);

@interface ZCComponentDatePickerView : ZCComponentDatePickerBaseView

/**
 *  1.显示时间选择器
 *
 *  @param title            标题
 *  @param dateType         日期显示类型
 *  @param defaultSelValue  默认选中的时间（值为空/值格式错误时，默认就选中现在的时间）
 *  @param resultBlock      选择结果的回调
 *
 */
+ (void)showDatePickerWithTitle:(NSString *)title
                       dateType:(UCARDatePickerMode)dateType
                defaultSelValue:(NSString *)defaultSelValue
                    resultBlock:(UCARDateResultBlock)resultBlock;

/**
 *  2.显示时间选择器（支持 设置自动选择 和 自定义主题颜色）
 *
 *  @param title            标题
 *  @param dateType         日期显示类型
 *  @param defaultSelValue  默认选中的时间（值为空/值格式错误时，默认就选中现在的时间）
 *  @param minDate          最小时间，可为空（请使用 NSDate+UCARPickerView 分类中和显示类型格式对应的方法创建 minDate）
 *  @param maxDate          最大时间，可为空（请使用 NSDate+UCARPickerView 分类中和显示类型格式对应的方法创建 maxDate）
 *  @param isAutoSelect     是否自动选择，即选择完(滚动完)执行结果回调，传选择的结果值
 *  @param themeColor       自定义主题颜色
 *  @param resultBlock      选择结果的回调
 *
 */
+ (void)showDatePickerWithTitle:(NSString *)title
                       dateType:(UCARDatePickerMode)dateType
                defaultSelValue:(NSString *)defaultSelValue
                        minDate:(NSDate *)minDate
                        maxDate:(NSDate *)maxDate
                   isAutoSelect:(BOOL)isAutoSelect
                     themeColor:(UIColor *)themeColor
                    resultBlock:(UCARDateResultBlock)resultBlock;

/**
 *  3.显示时间选择器（支持 设置自动选择、自定义主题颜色、取消选择的回调）
 *
 *  @param title            标题
 *  @param dateType         日期显示类型
 *  @param defaultSelValue  默认选中的时间（值为空/值格式错误时，默认就选中现在的时间）
 *  @param minDate          最小时间，可为空（请使用 NSDate+UCARPickerView 分类中和显示类型格式对应的方法创建 minDate）
 *  @param maxDate          最大时间，可为空（请使用 NSDate+UCARPickerView 分类中和显示类型格式对应的方法创建 maxDate）
 *  @param isAutoSelect     是否自动选择，即选择完(滚动完)执行结果回调，传选择的结果值
 *  @param themeColor       自定义主题颜色
 *  @param resultBlock      选择结果的回调
 *  @param cancelBlock      取消选择的回调
 *
 */
+ (void)showDatePickerWithTitle:(NSString *)title
                       dateType:(UCARDatePickerMode)dateType
                defaultSelValue:(NSString *)defaultSelValue
                        minDate:(NSDate *)minDate
                        maxDate:(NSDate *)maxDate
                   isAutoSelect:(BOOL)isAutoSelect
                     themeColor:(UIColor *)themeColor
                    resultBlock:(UCARDateResultBlock)resultBlock
                    cancelBlock:(UCARDateCancelBlock)cancelBlock;

@end
