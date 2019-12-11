//
//  UCARMonitorNewStore.h
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import "UCARMonitorConstants.h"
#import "UCARMonitorNewStoreORM.h"
#import "UCARMonitorUploader.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UCARMonitorAppName) {
    UCARMonitorAppNamePCARDriver = 0,       //合作司机端
    UCARMonitorAppNamePCAR = 1,             //专车
    UCARMonitorAppNameZuche = 2,            //租车
    UCARMonitorAppNameFCAR = 3,             //闪贷
    UCARMonitorAppNameMMC = 4,              //买买车
    UCARMonitorAppNameLuckyStore = 5,
    UCARMonitorAppNameLuckyCStore = 6,
    UCARMonitorAppNameLuckyClient = 7,
    UCARMonitorAppNameLuckyDispatch = 8,
    UCARMonitorAppNameYCC = 9,              //车管家
    UCARMonitorAppNameCaraid = 10,          //易捷助手
    UCARMonitorAppNameCarlock = 11,
    UCARMonitorAppNameOperation = 12,       //运营助手
    UCARMonitorAppNameCarInvApp = 13,       //盘点
    UCARMonitorAppNameCMT   = 14,             //车码头
    UCARMonitorAppNameBWCMT = 15,             // 宝沃新零售商户端
    UCARMonitorAppNameBWMaster = 17,          // 宝沃车主端
};

/**
 新事件存储器
 @note 该实例的统计方法不建议直接调用
 */
@interface UCARMonitorNewStore : NSObject <UCARMonitorUploaderDataSource>

/**
 App版本号
 */
@property (nonatomic, nonnull) NSString *appVersion;

/**
 用户ID
 @note 该值大多为数据库中的memberID
 */
@property (nonatomic, nonnull) NSString *userID;

/**
 客户端类型，default = UCARMonitorAppNameYCC
 */
@property (nonatomic) UCARMonitorAppName appName;


/**
 网络请求的uid
 @note 该值会在UCARNetwork中自动设置，App无需关注该值
 */
@property (nonatomic, nonnull) NSString *sessionID;


/**
 longitude
 */
@property (nonatomic, nonnull) NSString *longitude;


/**
 latitude
 */
@property (nonatomic, nonnull) NSString *latitude;


/**
 用户手机号
 */
@property (nonatomic, nonnull) NSString *mobile;


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
 存储异常事件
 
 @param code 事件编码
 @param stack 堆栈信息
 @param remark 扩展信息
 */
- (void)storeException:(nonnull NSString *)code
                 stack:(nonnull NSDictionary *)stack
                remark:(nonnull NSDictionary *)remark;


/**
 存储性能事件

 @param code 事件编码
 @param remark 扩展信息
 */
- (void)storePerformance:(nonnull NSString *)code remark:(nonnull NSDictionary *)remark;

/**
 存储DNS信息
 
 @param domain 域名
 @param IP 真实IP，后台返回
 @param hijackIP 被劫持的IP，该字段有值则表明被劫持
 @param remark 扩展信息
 */
- (void)storeDNS:(nonnull NSString *)domain
              IP:(nonnull NSString *)IP
        hijackIP:(nonnull NSString *)hijackIP
          remark:(nonnull NSDictionary *)remark;


/**
 存储日志信息

 @param tag 日志标记
 @param content 日志内容
 */
- (void)storeLog:(nonnull NSString *)tag content:(nonnull NSString *)content;

/**
 立即发送统计事件
 
 @param code 事件编码
 @param remark 扩展信息
 @note 若未设置userID，则该事件会被存储
 */
- (void)sendEvent:(nonnull NSString *)code remark:(nonnull NSDictionary *)remark;

@end
