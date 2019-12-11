//
//  UCARMonitorStore.h
//  UCARMonitor
//
//  Created by linux on 2018/7/6.
//

#import "UCARMonitorConstants.h"
#import "UCARMonitorUploader.h"
#import <Foundation/Foundation.h>

@class UCARMonitorOldStoreDriverCheating;

/**
 monitor协议版本
 
 - UCARMonitorStoreVersionNew: 新版本
 - UCARMonitorStoreVersionOld: 旧版本
 */
typedef NS_ENUM(NSInteger, UCARMonitorStoreVersion) {
    UCARMonitorStoreVersionNew,     //新版本
    UCARMonitorStoreVersionOld      //旧版本
};

/**
 Monitor Delegate
 */
@protocol UCARMonitorStoreDelegate <NSObject>


/**
 已发送数据
 
 @param code 事件编码
 @param remark 扩展信息
 */
- (void)didStoreEvent:(nonnull NSString *)code remark:(nonnull NSDictionary *)remark;

/**
 已发送页面事件
 
 @param pageName page class name
 @param action into || leave
 @param remark 扩展信息
 */
- (void)didStoreRoute:(nonnull NSString *)pageName
               action:(UCARMonitorStoreRouteAction)action
               remark:(nonnull NSDictionary *)remark;

@end

/**
 事件存储器，所有统计事件均有该实例进行搜集
 */
@interface UCARMonitorStore : NSObject

/**
 monitor协议版本，default = UCARMonitorStoreVersionNew
 @discussion 该值直接决定数据被转发至哪个版本示例，所以必须在设置sessionID和调用任意Monitor函数前设置
 @note 由于monitor被网络库依赖，所以改值必须在网络库初始化之前设置
 */
@property (nonatomic, assign) UCARMonitorStoreVersion version;

/**
 网络请求的uid
 @note 该值会在UCARNetwork中自动设置，App无需关注该值
 */
@property (nonatomic, nonnull, copy) NSString *sessionID;

/**
 关闭performance统计，default = NO
 @note set this prop in main queue
 */
@property (nonatomic, assign) BOOL filterPerformance;

/**
 标记当前页面是否已被监测过
 */
@property (nonatomic, assign) BOOL pageStuckMonitored;

/**
 事件上传器
 */
@property (nonatomic, readonly, nonnull) UCARMonitorUploader *uploader;

/**
 代理
 @note 注意：这个代理仅用于性能分析，有需求请与平台组联系。
 */
@property (nonatomic, nullable) id<UCARMonitorStoreDelegate> delegate;

/**
 返回一个Monitor单例

 @return sharedStore
 */
+ (nonnull instancetype)sharedStore;



/**
 标记App启动时间统计错误
 @note 此方法建议在存在引导页时调用
 */
- (void)markAppStartDurationMistake;

- (void)applicationDidFinishLaunchingWithOptions;

- (void)applicationWillResignActive;

- (void)applicationDidEnterBackground;

- (void)applicationWillEnterForeground;

- (void)applicationDidBecomeActive;

- (void)applicationDidReceiveMemoryWarning;

- (void)applicationWillTerminate;


/**
 record applicationOpenURL

 @param url openURL
 */
- (void)applicationOpenURL:(nonnull NSURL *)url;


/**
 首页渲染完成，用于标记冷启动结束
 */
- (void)homeVCViewDidAppear;

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
 反作弊数据验证
 
 @param driverCheating 验证数据
 */
- (void)storeDriverCheating:(nonnull UCARMonitorOldStoreDriverCheating *)driverCheating;

/**
 获取时间

 @return 时间字符串
 */
+ (nonnull NSString *)getTimeString;

/**
 json转字符串

 @param parameters dict
 @return jsonstr
 */
+ (nonnull NSString *)stringFromJSONObject:(nullable NSDictionary *)parameters;

/**
 立即发送统计事件

 @param code 事件编码
 @param remark 扩展信息
 @note 若未设置userID，则该事件会被存储
 */
- (void)sendEvent:(nonnull NSString *)code remark:(nonnull NSDictionary *)remark;


@end
