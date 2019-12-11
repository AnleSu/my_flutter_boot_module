//
//  UCARRobot.m
//  UCARRobot
//
//  Created by suzhiqiu on 2019/6/28.
//

#import "UCARRobot.h"
#import "DoraemonManager.h"
#import "UCAREnviromentPlugin.h"
#import "UCAREnvironmentManager.h"
#import "DoraemonHomeWindow.h"

@implementation UCARRobot

//安装
+ (void)install{
    [self addUCarPlugin];
    [[DoraemonManager shareInstance] install];
}
//添加UCar的插件
+ (void)addUCarPlugin{
    NSString *moduleName = @"";
    moduleName =DoraemonLocalizedString(@"常用工具");
    [[DoraemonManager shareInstance] addPluginWithTitle:@"网络环境"
                                                   icon:@"doraemon_network"
                                                   desc:nil
                                             pluginName:NSStringFromClass([UCAREnviromentPlugin class])
                                               atModule:moduleName];
}
//关闭当前窗口
+ (void)closeWindow{
    [[DoraemonHomeWindow shareInstance] hide];
}
//设置自定义切换环境界面Class
+ (void)setEnvClass:(Class)evnClass {
    if(evnClass) {
        [[UCAREnvironmentManager shareManager] setEnvClass:evnClass];
    }
}
//设置请求conent解密入口
+ (void)setHTTPContentDecrypt:(DecryptBlock)decryptBlock {
    if (decryptBlock) {
        [UCARNetFlowManager shareManager].decryptBlock = decryptBlock;
    }
}


@end
