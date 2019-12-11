//
//  UCARCMTransitHttpClient.h
//  CMT
//
//  Created  by hong.zhu on 2019/3/6.
//  Copyright © 2019年 linux. All rights reserved.
//

#import "UCARMAPIHttpClient.h"

NS_ASSUME_NONNULL_BEGIN

/**
 车码头-网络请求中转
 */
@interface UCARCMTransitHttpClient : UCARMAPIHttpClient

/**
 单例
 */
+ (nonnull instancetype)sharedClient;

@end

NS_ASSUME_NONNULL_END
