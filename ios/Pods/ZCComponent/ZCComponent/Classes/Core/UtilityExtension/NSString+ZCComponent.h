//
//  NSString+UCARUIKit.h
//  Pods-ZCComponent_Example
//
//  Created by 郑熙 on 2019/4/25.
//

@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ZCComponent)

/**
 *  是否包含substring(区分大小写)
 *
 *  @param substring 子字符串
 *
 *  @return Returns YES if founded, NO if not
 */
- (BOOL)hasString:(NSString * _Nonnull)substring;

/**
 *  是否包含substring
 *
 *  @param substring     子字符串
 *  @param caseSensitive 是否区分大小写
 *
 *  @return Returns YES if founded, NO if not
 */
- (BOOL)hasString:(NSString * _Nonnull)substring
    caseSensitive:(BOOL)caseSensitive;

/**
 *  是否是email格式
 *
 *  @return Returns YES if it is, NO if not
 */
- (BOOL)isEmail;

/**
 *  是否是email格式
 *
 *  @param email 用于检验的email
 *
 *  @return Returns YES if it is, NO if not
 */
+ (BOOL)isEmail:(NSString * _Nonnull)email;

/**
 *  将string url编码
 *
 *  @return Returns the encoded NSString
 */
- (NSString * _Nonnull)URLEncode;

/**
 *  计算string的高度
 *
 *  @param width 用于计算的宽度，高度不限
 *  @param font  用于计算的font大小
 *
 *  @return 计算好的高度
 */
- (CGFloat)heightForWidth:(float)width
                  andFont:(UIFont * _Nonnull)font;

@end

NS_ASSUME_NONNULL_END
