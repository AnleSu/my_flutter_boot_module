//
//  NSDate+UCARPickerView.h
//  UCARPickerViewDemo
//
//  Created by szq on 2019/4/25.
//  Copyright © 2019年 ucar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (ZCComponentDatePickerView)
/// 获取指定date的详细信息
@property (readonly) NSInteger ucar_year;    // 年
@property (readonly) NSInteger ucar_month;   // 月
@property (readonly) NSInteger ucar_day;     // 日
@property (readonly) NSInteger ucar_hour;    // 时
@property (readonly) NSInteger ucar_minute;  // 分
@property (readonly) NSInteger ucar_second;  // 秒
@property (readonly) NSInteger ucar_weekday; // 星期

/** 创建 date */
/** yyyy */
+ (nullable NSDate *)ucar_setYear:(NSInteger)year;
/** yyyy-MM */
+ (nullable NSDate *)ucar_setYear:(NSInteger)year month:(NSInteger)month;
/** yyyy-MM-dd */
+ (nullable NSDate *)ucar_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
/** yyyy-MM-dd HH:mm */
+ (nullable NSDate *)ucar_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;
/** MM-dd HH:mm */
+ (nullable NSDate *)ucar_setMonth:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;
/** MM-dd */
+ (nullable NSDate *)ucar_setMonth:(NSInteger)month day:(NSInteger)day;
/** HH:mm */
+ (nullable NSDate *)ucar_setHour:(NSInteger)hour minute:(NSInteger)minute;

/** 日期和字符串之间的转换：NSDate --> NSString */
+ (nullable  NSString *)ucar_getDateString:(NSDate *)date format:(NSString *)format;
/** 日期和字符串之间的转换：NSString --> NSDate */
+ (nullable  NSDate *)ucar_getDate:(NSString *)dateString format:(NSString *)format;
/** 获取某个月的天数（通过年月求每月天数）*/
+ (NSUInteger)ucar_getDaysInYear:(NSInteger)year month:(NSInteger)month;

/**  获取 日期加上/减去某天数后的新日期 */
- (nullable NSDate *)ucar_getNewDate:(NSDate *)date addDays:(NSTimeInterval)days;

/**
 *  比较两个时间大小（可以指定比较级数，即按指定格式进行比较）
 */
- (NSComparisonResult)ucar_compare:(NSDate *)targetDate format:(NSString *)format;

@end

NS_ASSUME_NONNULL_END
