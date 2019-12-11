//
//  UCarMapFundation.m
//  UCarMapFundation
//
//  Created by huangyi on 3/16/17.
//  Copyright © 2017 UCar. All rights reserved.
//

#import "UCarMapFundation.h"

NSString* const AMAP_KEY = @"AmapKey";
NSString* const BAIDU_MAP_KEY = @"BaiduMapKey";

@implementation UCarMapFundation

@synthesize keys;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static UCarMapFundation *instance = nil;
    dispatch_once( &onceToken, ^{
        instance = [[UCarMapFundation alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        keys = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
