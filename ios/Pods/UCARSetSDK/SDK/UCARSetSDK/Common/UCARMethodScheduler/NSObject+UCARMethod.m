//
//  NSObject+UCARMethod.m
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//  from: https://github.com/dsxNiubility/WMScheduler.git

#import "NSObject+UCARMethod.h"

@implementation NSObject (UCARMethod)

- (nullable id)ucarmethod_executeMethod:(nullable SEL)selector {
    return [[UCARMethodScheduler sharedInstance] ucarmethod_executeInstanceMethod:selector inTarget:self params:nil];
}

- (nullable id)ucarmethod_executeMethod:(nullable SEL)selector params:(nullable NSArray *)params {
    return [[UCARMethodScheduler sharedInstance] ucarmethod_executeInstanceMethod:selector inTarget:self params:params];
}

@end
