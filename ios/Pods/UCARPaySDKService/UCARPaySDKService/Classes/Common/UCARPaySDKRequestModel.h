//
//  UCARPaySDKRequestModel.h
//  UCARPlatform
//
//  Created  by hong.zhu on 2019/2/15.
//  Copyright © 2019年 UCar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCARPayConstConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCARPaySDKRequestModel : NSObject

/**
 通过 paySDKType 创建
 */
+ (instancetype)paySDKRequestModelWithType:(UCARPaySDKType)paySDKType;

/**
 支付方式
 */
@property (nonatomic, assign, readonly) UCARPaySDKType paySDKType;

/**
 支付参数
 
 @note 不同的支付方式, 各有千秋
 */
@property (nonatomic, strong) id params;

/**
 控制器
 */
@property (nonatomic, strong) UIViewController *viewController;

@end

NS_ASSUME_NONNULL_END
