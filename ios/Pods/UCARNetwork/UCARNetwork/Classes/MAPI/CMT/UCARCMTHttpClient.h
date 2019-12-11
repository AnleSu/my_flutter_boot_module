//
//  UCARCMTHttpClient.h
//  CMT
//
//  Created by hong.zhu on 2018/8/8.
//  Copyright © 2018年 linux. All rights reserved.
//

#import "UCARCMTransitHttpManager.h"

/**
 车码头
 */
@interface UCARCMTHttpClient : UCARCMTransitHttpManager

/**
 单例

 @return httpManager 单例
 */
+ (nonnull instancetype)sharedClient;

@end
