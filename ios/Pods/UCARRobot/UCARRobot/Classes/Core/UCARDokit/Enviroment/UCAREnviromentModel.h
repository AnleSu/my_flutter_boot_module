//
//  UCAREnviromentModel.h
//  UCARRobot
//
//  Created by suzhiqiu on 2019/7/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UCAREnviromentType) {
    UCAREnviromentTypeDevelop = 1,    //测试环境
    UCAREnviromentTypePreProduct = 2, //预发环境
    UCAREnviromentTypeProduct = 3,    //正式环境
};

@interface UCAREnviromentModel : NSObject<NSSecureCoding>

@property (nonatomic, assign) UCAREnviromentType envType;//环境类型
@property (nonatomic, copy) NSString *name;//en名称
@property (nonatomic, copy) NSString *desc;//cn名称
@property (nonatomic, assign) BOOL isOpen;//是否当前环境

    
@end

NS_ASSUME_NONNULL_END
