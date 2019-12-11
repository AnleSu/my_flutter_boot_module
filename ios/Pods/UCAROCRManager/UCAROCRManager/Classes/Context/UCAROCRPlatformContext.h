//
//  UCAROCRPlatformContext.h
//  Pods-UCAROCRManager_Example
//
//  Created by Link on 2019/8/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UCAROCRPlatformContext : NSObject
+ (instancetype)shareInstance;

// 静态资源相关
+ (NSBundle *)getCurrentBundle;                                             // 提供资源Bundle对象
+ (UIImage *)imageNamed:(NSString *)name;                                   // 提供获取图片方法
@end

NS_ASSUME_NONNULL_END
