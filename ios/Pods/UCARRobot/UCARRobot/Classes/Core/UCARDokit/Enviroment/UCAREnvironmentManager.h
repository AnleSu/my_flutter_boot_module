//
//  UCAREnvironmentManager.h
//  UCARRobot
//
//  Created by suzhiqiu on 2019/7/2.
//

#import <Foundation/Foundation.h>
#import "UCAREnviromentModel.h"

NS_ASSUME_NONNULL_BEGIN


/*点击列表开始修改环境通知*/
static NSString *const UCAREnvironmentDidChangeNotification = @"UCAREnvironmentDidChangeNotification";
/*点击列表开始修改通知*/
static NSString *const UCAREnvironmentEndChangeNotification = @"UCAREnvironmentEndChangeNotification";

@interface UCAREnvironmentManager : NSObject

@property (nonatomic ,strong) Class envClass;
@property (nonatomic ,copy) NSArray *envArray;

//单例
+ (UCAREnvironmentManager *)shareManager;
//当前环境类型
+ (UCAREnviromentModel *)currentEnviroment;
//设置当前环境
+ (void)setCurrentEnviroment:(UCAREnviromentModel *)model;

@end

NS_ASSUME_NONNULL_END
