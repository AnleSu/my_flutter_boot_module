//
//  UCarMapImplFactory.h
//  Pods-UCarMapExample
//
//  Created by 戈宝福 on 2018/4/19.
//  
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UCarMapFundation/UCarMapFundation.h>
#import "UCarMapSearchImpl.h"

@interface UCarMapSearchImplFactory : NSObject

+ (id<UCarMapSearchImpl>) GetMapImpl: (UCarMapImplementType)newImplementType;

@end
