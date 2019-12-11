//
//  NSObject+UCARMethod.h
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//  from: https://github.com/dsxNiubility/WMScheduler.git

#import <Foundation/Foundation.h>
#import "UCARMethodScheduler.h"

#define ucarmethod_scheduler_getClass(className) ([[UCARMethodScheduler sharedInstance] getClassWithName:className])

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (UCARMethod)

- (nullable id)ucarmethod_executeMethod:(nullable SEL)selector;
- (nullable id)ucarmethod_executeMethod:(nullable SEL)selector params:(nullable NSArray *)params;

@end

NS_ASSUME_NONNULL_END
