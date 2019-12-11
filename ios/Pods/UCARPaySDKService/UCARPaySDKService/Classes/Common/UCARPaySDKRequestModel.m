//
//  UCARPaySDKRequestModel.m
//  UCARPlatform
//
//  Created  by hong.zhu on 2019/2/15.
//  Copyright © 2019年 UCar. All rights reserved.
//

#import "UCARPaySDKRequestModel.h"

@implementation UCARPaySDKRequestModel

/**
 通过 paySDKType 创建
 */
+ (instancetype)paySDKRequestModelWithType:(UCARPaySDKType)paySDKType {
    UCARPaySDKRequestModel *requestModel = [self new];
    requestModel->_paySDKType = paySDKType;
    return requestModel;
}

@end
