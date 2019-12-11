//
//  UCARMAPIHttpConfig.m
//  Pods
//
//  Created by linux on 2017/7/25.
//
//

#import "UCARMAPIHttpConfig.h"

@implementation UCARMAPIHttpConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _allowCache = YES;

        _refreshKeyRequest = NO;

        _autoDealMAPIError = YES;
        _customDealMAPIError = NO;
        _autoDealNetworkError = YES;
    }
    return self;
}

@end
