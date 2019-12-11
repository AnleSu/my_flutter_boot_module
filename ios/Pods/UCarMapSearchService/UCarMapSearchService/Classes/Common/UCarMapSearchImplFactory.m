//
//  UCarMapImplFactory.m
//  Pods-UCarMapExample
//
//  Created by 戈宝福 on 2018/4/19.
//  
//


#import "UCarMapSearchImplFactory.h"

@implementation UCarMapSearchImplFactory

+ (id<UCarMapSearchImpl>) GetMapImpl: (UCarMapImplementType)newImplementType
{
    id<UCarMapSearchImpl> impl;
    switch (newImplementType)
    {
        case UCarMapImplementType_AMap:
        {
            Class class = NSClassFromString(@"UCarAMapSearchImpl");
            impl = [[class alloc] init];
            break;
        }
        case UCarMapImplementType_Baidu:
        {
            Class class = NSClassFromString(@"UCarMapSearchBaiduImpl");
            impl = [[class alloc] init];
            break;
        }
        default:
            break;
    }
    return impl;
}

@end
