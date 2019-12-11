//
//  UIImage+UCARSize.h
//  UCARUtility_Example
//
//  Created  by hong.zhu on 2019/3/5.
//  Copyright © 2019年 linux. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (UCARSize)

/**
 图片压缩

 @param maxLength 限制的最大长度
 @return 返回合适的 NSData
 */
- (NSData *)imageCompressWithMaxLength:(NSUInteger)maxLength;

@end

NS_ASSUME_NONNULL_END
