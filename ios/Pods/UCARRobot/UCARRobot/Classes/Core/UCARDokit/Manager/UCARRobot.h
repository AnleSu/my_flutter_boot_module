//
//  UCARRobot.h
//  UCARRobot
//
//  Created by suzhiqiu on 2019/6/28.
//

#import <Foundation/Foundation.h>
#import "UCARNetFlowManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCARRobot : NSObject

//安装
+ (void)install;
//关闭当前窗口
+ (void)closeWindow;


/**
 设置自定义切换环境界面Class

 @param evnClass 自定义界面的VC 的Class
 */
+ (void)setEnvClass:(Class)evnClass;
/**
 设置请求conent解密入口 
 [UCARApp]: UCARTravelHttpClient
 [CMT]: UCARCMTransitHttpClient
 [Driver]: UCARDriverHttpClient
 [WCC]: WCCHttpManager
 [YCC]: YCCHttpManager
 [YY]: UCARYYHttpClient
 @param decryptBlock 返回解密后的Content
 */
+ (void)setHTTPContentDecrypt:(DecryptBlock)decryptBlock;





@end

NS_ASSUME_NONNULL_END
