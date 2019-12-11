//
//  UCARShareQQDelegate.h
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UCARShareQQ;

NS_ASSUME_NONNULL_BEGIN

@protocol UCARShareQQDelegate <NSObject>

// 返回结果
- (void)shareQQ:(UCARShareQQ*)shareQQ result:(NSInteger)result message:(NSString*)message;

@end

NS_ASSUME_NONNULL_END
