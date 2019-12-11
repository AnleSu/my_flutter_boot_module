//
//  UCARMonitorOldStore.h
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import "UCARMonitorConstants.h"
#import "UCARMonitorOldStoreORM.h"
#import "UCARMonitorUploader.h"
#import <Foundation/Foundation.h>

/**
 旧事件存储器
 @discussion 目前只有专车司机端和专车客户端使用
 @note 该实例的统计方法不建议直接调用
 */
@interface UCARMonitorOldStore : NSObject <UCARMonitorUploaderDataSource>

/**
 司机端/客户端
 */
@property (nonatomic, nonnull) NSString *userType;

/**
 App版本号
 */
@property (nonatomic, nonnull) NSString *appVersion;

/**
 网络请求的uid
 @note 该值会在UCARNetwork中自动设置，App无需关注该值
 */
@property (nonatomic, nonnull) NSString *sessionID;

/**
 用户ID
 @discussion 该值为合成值，依赖userID和手机号
 @note 该值大多为数据库中的memberID
 */
@property (nonatomic, nonnull) NSString *userID;

/**
 城市ID
 */
@property (nonatomic, nonnull) NSString *cityID;

/**
 事件上传器
 */
@property (nonatomic, readonly, nonnull) UCARMonitorUploader *uploader;

/**
 返回一个Monitor单例
 
 @return sharedStore
 */
+ (nonnull instancetype)sharedStore;

/**
 开启上传，在恢复至前台时调用
 @note 该方法在初始化时会自动调用
 */
- (void)restartUpload;

/**
 停止上传，app进后台时调用
 */
- (void)stopUpload;

/**
 存储设备信息
 
 @param remark 扩展信息
 */
- (void)storeDevice:(nonnull NSDictionary *)remark;

/**
 存储统计事件
 
 @param code 事件编码
 @param remark 扩展信息
 */
- (void)storeEvent:(nonnull NSString *)code remark:(nonnull NSDictionary *)remark;

/**
 存储页面事件
 
 @param pageName page class name
 @param action into || leave
 @param remark 扩展信息
 */
- (void)storeRoute:(nonnull NSString *)pageName
            action:(UCARMonitorStoreRouteAction)action
            remark:(nonnull NSDictionary *)remark;


/**
 存储DNS信息

 @param domain 域名
 @param IP IP
 @discussion 该事件不再统计，不要调用
 */
- (void)storeDNS:(nonnull NSString *)domain IP:(nonnull NSString *)IP;

/**
 存储异常事件
 
 @param code 事件编码
 @param stack 堆栈信息
 @param remark 扩展信息
 */
- (void)storeException:(nonnull NSString *)code
                 stack:(nonnull NSDictionary *)stack
                remark:(nonnull NSDictionary *)remark;

/**
 存储日志信息
 
 @param tag 日志标记
 @param content 日志内容
 */
- (void)storeLog:(nonnull NSString *)tag content:(nonnull NSString *)content;

/**
 反作弊数据验证

 @param driverCheating 验证数据
 */
- (void)storeDriverCheating:(nonnull UCARMonitorOldStoreDriverCheating *)driverCheating;

/**
 立即发送统计事件
 
 @param code 事件编码
 @param remark 扩展信息
 @note 若未设置userID，则该事件会被存储
 */
- (void)sendEvent:(nonnull NSString *)code remark:(nonnull NSDictionary *)remark;

@end
