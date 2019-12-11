//
//  UCARBaseShare.h
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UCARShareItem;

NS_ASSUME_NONNULL_BEGIN

@interface UCARBaseShare : NSObject

/**
  设置 delegate 的值
 */
- (instancetype)initWithDelegate:(id)delegate;

/**
 代理
 */
@property (nonatomic, weak, readonly) id delegate;

/**
 是否安装客户端
 */
+ (BOOL)isAppInstalled;

/**
 发微博
 */
- (NSString*)shareWithItem:(UCARShareItem*)item;

// 图片压缩
- (NSData *)imageCompressWithMaxLength:(NSUInteger)maxLength image:(UIImage *)image;

/// 下载图片
- (void)loadImageWithURLSrtring:(NSString *)URLString completed:(void(^)(UIImage * _Nullable image, NSData * _Nullable data))completedBlock;

@end

NS_ASSUME_NONNULL_END
