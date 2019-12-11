//
//  UIImage+UCARSize.m
//  UCARUtility_Example
//
//  Created  by hong.zhu on 2019/3/5.
//  Copyright © 2019年 linux. All rights reserved.
//

#import "UIImage+UCARSize.h"

@implementation UIImage (UCARSize)

// 图片压缩
- (NSData *)imageCompressWithMaxLength:(NSUInteger)maxLength {
    NSData *imageData = UIImageJPEGRepresentation(self, 1.0f);
    CGFloat compressionQuality = 0.5;
    CGFloat minCompressionQuality = 0.01;
    if (imageData.length > maxLength) {
        minCompressionQuality = 0.1;
    }
    
    // 按质量压缩图片
    while (imageData.length > maxLength && compressionQuality > minCompressionQuality) {
        imageData = UIImageJPEGRepresentation(self, compressionQuality);
        compressionQuality *= 0.6;
    }
    
    // 质量压缩不够时，再进行尺寸压缩
    UIImage *resultImage = [UIImage imageWithData:imageData];
    NSUInteger lastDataLength = 0;
    while (imageData.length > maxLength && imageData.length != lastDataLength) {
        lastDataLength = imageData.length;
        CGFloat ratio = (CGFloat)maxLength / imageData.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        // Use image to draw (drawInRect:), image is larger but more compression time
        // Use result image to draw, image is smaller but less compression time
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        imageData = UIImageJPEGRepresentation(resultImage, 1);
    }
    return imageData;
}

@end
