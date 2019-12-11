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
#import "UCarLocationImpl.h"

@interface UCarLocationImplFactory : NSObject

+ (id<UCarLocationImpl>) GetLocationImpl: (UCarMapImplementType)newImplementType;

@end
