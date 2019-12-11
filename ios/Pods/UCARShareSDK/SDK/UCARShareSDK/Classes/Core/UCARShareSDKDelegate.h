//
//  UCARShareSDKDelegate.h
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCARShareConstants.h"

@class UCARShareSDK;

NS_ASSUME_NONNULL_BEGIN

@protocol UCARShareSDKDelegate <NSObject>

/**
 ShareSDK 结果返回
 */
- (void)shareSDK:(UCARShareSDK *)shareSDK result:(UCARShareSDKResult)result message:(NSString*)message;

@end

NS_ASSUME_NONNULL_END
