//
//  UCARMonitorNewStoreORM.h
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import <Foundation/Foundation.h>

/**
 统计事件基类
 @discussion http://wiki.10101111.com/pages/viewpage.action?pageId=96502100
 */
@interface UCARMonitorNewStoreCommonInfo : NSObject <NSSecureCoding>

/**
 App版本号
 */
@property (nonatomic, nonnull) NSString *app_version;

/**
 用户唯一id
 */
@property (nonatomic, nonnull) NSString *user_id;

/**
 区分APP标识
 */
@property (nonatomic, nonnull) NSString *app_name;

/**
 网络请求会话ID
 */
@property (nonatomic, nonnull) NSString *session_id;

/**
 会话ID
 @note 该值=session_id
 */
@property (nonatomic, nonnull) NSString *token_id;

/**
 APP下载渠道
 */
@property (nonatomic, nonnull, readonly) NSString *channel;

/**
 经度
 */
@property (nonatomic, nonnull) NSString *longitude;

/**
 纬度
 */
@property (nonatomic, nonnull) NSString *latitude;

/**
 手机IMEI号
 @note 该值实际为device_token
 */
@property (nonatomic, nonnull, readonly) NSString *device_imei;

/**
 手机设备类型（android/iOS）
 */
@property (nonatomic, nonnull, readonly) NSString *platform;

/**
 手机号
 */
@property (nonatomic, nonnull) NSString *mobile;

/**
 事件编号
 */
@property (nonatomic, nonnull, readonly) NSString *event_id;

/**
 当前页面信息
 */
@property (nonatomic, nonnull, readonly) NSString *current_info;

/**
 事件时间
 */
@property (nonatomic, nonnull, readonly) NSString *time;

/**
 将事件转换为字典

 @return 事件数据
 */
- (nonnull NSDictionary *)convertSelfToDict;

@end


/**
 设备信息
 */
@interface UCARMonitorNewStoreDevice : UCARMonitorNewStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;

/**
 手机品牌
 */
@property (nonatomic, nonnull, readonly) NSString *device_brand;

/**
 手机型号
 */
@property (nonatomic, nonnull, readonly) NSString *device_model;

/**
 手机状态（是否root、越狱）
 */
@property (nonatomic, nonnull, readonly) NSString *system_status;

/**
 运营商（联通、电信）
 */
@property (nonatomic, nonnull, readonly) NSString *mobile_operator;

/**
 网络类型（2G/3G/4G）
 */
@property (nonatomic, nonnull, readonly) NSString *net_type;

/**
 扩展信息
 */
@property (nonatomic, nonnull) NSString *device_remark;

/**
 分辨率
 */
@property (nonatomic, nonnull, readonly) NSString *device_screen_resolution;

/**
 系统版本
 */
@property (nonatomic, nonnull, readonly) NSString *device_system_version;

@end


/**
 Event事件
 */
@interface UCARMonitorNewStoreEvent : UCARMonitorNewStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;

/**
 事件名称
 @discussion 为保持新老表统一，不统计该字段
 */
@property (nonatomic, nonnull, readonly) NSString *event_name;


/**
 事件编码
 */
@property (nonatomic, nonnull) NSString *event_code;


/**
 扩展信息
 */
@property (nonatomic, nonnull) NSString *event_remark;

@end


/**
 页面事件
 */
@interface UCARMonitorNewStoreRoute : UCARMonitorNewStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;

/**
 页面编码
 */
@property (nonatomic, nonnull) NSString *route_activity_code;

/**
 页面进入时间
 */
@property (nonatomic, nonnull) NSString *route_start_time;

/**
 页面停留时间（仅leave使用）
 */
@property (nonatomic, nonnull) NSString *route_duration;

/**
 页面离开时间（仅leave使用）
 */
@property (nonatomic, nonnull) NSString *route_end_time;

/**
 进入(into)/离开(leave)
 */
@property (nonatomic, nonnull) NSString *action;

/**
 扩展信息
 */
@property (nonatomic, nonnull) NSString *route_remark;

@end


/**
 异常事件
 */
@interface UCARMonitorNewStoreException : UCARMonitorNewStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;

/**
 异常编码
 */
@property (nonatomic, nonnull) NSString *exception_code;

/**
 扩展信息
 */
@property (nonatomic, nonnull) NSString *exception_remark;

/**
 异常堆栈信息
 */
@property (nonatomic, nonnull) NSString *exception_stack;

@end


/**
 性能事件
 */
@interface UCARMonitorNewStorePerformance : UCARMonitorNewStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;


/**
 事件编码
 */
@property (nonatomic, nonnull) NSString *perf_code;

/**
 扩展信息
 */
@property (nonatomic, nonnull) NSString *perf_remark;

@end


/**
 DNS信息
 */
@interface UCARMonitorNewStoreDNS : UCARMonitorNewStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;

/**
 域名
 */
@property (nonatomic, nonnull) NSString *device_domain;

/**
 劫持IP
 */
@property (nonatomic, nonnull) NSString *dns_hijack_ip;

/**
 真实IP
 */
@property (nonatomic, nonnull) NSString *dns_ip;

/**
 扩展信息
 */
@property (nonatomic, nonnull) NSString *dns_remark;

@end


/**
 日志信息
 */
@interface UCARMonitorNewStoreLog : UCARMonitorNewStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;

/**
 日志标签
 */
@property (nonatomic, nonnull) NSString *log_tag;

/**
 日志内容
 */
@property (nonatomic, nonnull) NSString *log_content;

@end
