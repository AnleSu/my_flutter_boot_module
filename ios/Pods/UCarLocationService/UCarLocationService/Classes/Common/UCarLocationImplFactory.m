//
//  UCarMapImplFactory.m
//  Pods-UCarMapExample
//
//  Created by 戈宝福 on 2018/4/19.
//  
//

#import "UCarLocationImplFactory.h"

@implementation UCarLocationImplFactory

+ (id<UCarLocationImpl>) GetLocationImpl: (UCarMapImplementType)newImplementType
{
    id<UCarLocationImpl> impl;
    switch (newImplementType)
    {
        case UCarMapImplementType_AMap:
        {
            Class class = NSClassFromString(@"UCARLocationAMapImpl");
            impl = [[class alloc] init];
            break;
        }
        case UCarMapImplementType_Baidu:
        {
            Class class = NSClassFromString(@"UCARLocationBaiduImpl");
            impl = [[class alloc] init];
            break;
        }
        default:
            break;
    }
    return impl;
}

@end
