//
//  MGDefaultBottomManager.h
//  MGLivenessDetection
//
//  Created by 张英堂 on 16/4/13.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import <UIKit/UIKit.h>

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ([[UIScreen mainScreen] currentMode].size.height == 2436) : NO)

#import "MGBaseBottomManager.h"


@interface MGDefaultBottomManager : MGBaseBottomManager


@end
