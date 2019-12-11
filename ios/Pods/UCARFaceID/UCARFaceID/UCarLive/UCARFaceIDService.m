//
//  UCARFaceIDService.m
//  UCARDemo
//
//  Created by 宣佚 on 2017/6/20.
//  Copyright © 2017年 UCAR. All rights reserved.
//

#import "UCARFaceIDService.h"
#import "MGBaseKit.h"

@implementation UCARFaceIDService

+ (void)startService {
    
    UCarFRService *ucarFRService = [UCarFRService sharedInstance];
#ifdef DEBUG
    ucarFRService.debugMode = YES;
#else
    ucarFRService.debugMode = NO;
#endif
    //暂测试使用，正式环境会配置各个业务线的APPID & APPTOKEN
    if (ucarFRService.debugMode) {
        [ucarFRService startWithAppId:@"fcar" appToken:@"fcartest"];
    }else {
        [ucarFRService startWithAppId:@"ucarios" appToken:@"bqrfsnak"];
    }
}

@end
