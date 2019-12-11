//
//  UCARShareWXDelegate.h
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UCARShareWX;

NS_ASSUME_NONNULL_BEGIN

@protocol UCARShareWXDelegate <NSObject>

// 返回结果
- (void)shareWX:(UCARShareWX*)shareWX result:(NSInteger)result message:(NSString*)message;

@end

NS_ASSUME_NONNULL_END
