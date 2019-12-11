//
//  UCAREnviromentPlugin.m
//  AFNetworking
//
//  Created by suzhiqiu on 2019/7/2.
//

#import "UCAREnviromentPlugin.h"
#import "UCAREnviromentListViewController.h"
#import "DoraemonUtil.h"
#import "UCAREnvironmentManager.h"

@implementation UCAREnviromentPlugin
    
    
- (void)pluginDidLoad{
    id vc = nil;
    if ([UCAREnvironmentManager shareManager].envClass){
        Class class = [UCAREnvironmentManager shareManager].envClass;
        vc = [[class alloc] init];
    }else {
        vc = [[UCAREnviromentListViewController alloc] init];
    }
    [DoraemonUtil openPlugin:vc];
}

@end
