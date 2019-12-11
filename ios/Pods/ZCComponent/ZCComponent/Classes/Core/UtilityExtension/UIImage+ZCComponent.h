//
//  UIImage+UCARUIKit.h
//  Pods-ZCComponent_Example
//
//  Created by 郑熙 on 2019/4/25.
//

@import Foundation;
@import UIKit;
@import Accelerate;

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ZCComponent)

/**
 根据颜色创建1x1大小的image
 
 @param color  The color.
 */
+ (UIImage * _Nonnull)imageWithColor:(UIColor * _Nonnull)color;

/**
 *  创建模糊图
 *
 *  @param blur 模糊半径 范围：0.0~1.0
 *
 *  @return Returns the transformed image
 */
- (UIImage * _Nonnull)blurImageWithBlur:(CGFloat)blur;

/**
 从pdf文件or文件地址里创建的图
 
 @discussion If the PDF has multiple page, is just return's the first page's
 content. Image's scale is equal to current screen's scale, size is same as
 PDF's origin size.
 
 @param dataOrPath PDF data in `NSData`, or PDF file path in `NSString`.
 
 @return 返回图片，如果解析错误，返回nil
 */
+ (nullable UIImage *)imageWithPDF:(id)dataOrPath;

/**
 从pdf文件or文件地址里创建的图
 
 @discussion If the PDF has multiple page, is just return's the first page's
 content. Image's scale is equal to current screen's scale.
 
 @param dataOrPath  PDF data in `NSData`, or PDF file path in `NSString`.
 
 @param size     指定图片的尺寸
 
 @return 返回图片，如果解析错误，返回nil
 */
+ (nullable UIImage *)imageWithPDF:(id)dataOrPath size:(CGSize)size;

/**
 Tint the image in alpha channel with the given color.
 
 @param color  The color.
 */
- (nullable UIImage *)imageByTintColor:(UIColor *)color;

/**
 *  保存到相册
 */
- (void)savedToAlbum:(void (^)(void))completeBlock failBlock:(void (^)(void))failBlock;

@end

NS_ASSUME_NONNULL_END
