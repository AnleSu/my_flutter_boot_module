//
//  UCARHttpBaseConfig.m
//  UCar
//
//  Created by KouArlen on 16/3/8.
//  Copyright © 2016年 zuche. All rights reserved.
//

#import "UCARHttpBaseConfig.h"
#import <UCARUtility/UCARUtility.h>

@implementation UCARHttpBaseConfig

+ (instancetype)defaultConfig {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _domain = nil;
        _subURL = nil;
        _parameters = nil;
        _httpMethod = UCARHttpMethodGet;
        _runInBackQueue = YES;
        _httpdnsEnable = YES;
        _httpsEnable = YES;

        _eventID = [UCAREventIDGenerator generateEventID];

        _needParse = YES;
        _needDecrypt = NO;
        _decryptKey = nil;

        _requestSendTime = 0;
    }
    return self;
}

@end
