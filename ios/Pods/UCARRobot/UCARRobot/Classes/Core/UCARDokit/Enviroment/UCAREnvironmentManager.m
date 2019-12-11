//
//  UCAREnvironmentManager.m
//  UCARRobot
//
//  Created by suzhiqiu on 2019/7/2.
//

#import "UCAREnvironmentManager.h"

NSString *const STORE_UCAREnvironment = @"STORE_UCAREnvironment";

@implementation UCAREnvironmentManager
    
//单例
+ (UCAREnvironmentManager *)shareManager{
    static UCAREnvironmentManager *sharedManager= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[UCAREnvironmentManager alloc] init];
    });
    return sharedManager;
}

+ (UCAREnviromentModel *)currentEnviroment{
    UCAREnviromentModel * model = nil;
#ifdef DEBUG
    NSData *data  = [[NSUserDefaults standardUserDefaults] objectForKey:STORE_UCAREnvironment];
    if (data){
        model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
#endif
    return model;
}
    
+ (void)setCurrentEnviroment:(UCAREnviromentModel *)model {
#ifdef DEBUG
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    if(!data){
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:STORE_UCAREnvironment];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}

@end
