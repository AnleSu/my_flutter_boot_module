//
//  UCARMonitorOldStoreORM.h
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import <Foundation/Foundation.h>

/**
 统计事件基类
 */
@interface UCARMonitorOldStoreCommonInfo : NSObject <NSSecureCoding>

/**
 手机IMEI号
 @note 该值实际为device_token
 */
@property (nonatomic, nonnull, readonly) NSString *device_imei;

/**
 手机openid
 @note 该值实际为device_token
 */
@property (nonatomic, nonnull, readonly) NSString *device_openid;


/**
 手机设备类型（android/iOS）
 */
@property (nonatomic, nonnull, readonly) NSString *device_type;

/**
 APP下载渠道
 */
@property (nonatomic, nonnull, readonly) NSString *device_channel;


/**
 司机端/客户端
 */
@property (nonatomic, nonnull) NSString *user_type;

/**
 事件编号
 */
@property (nonatomic, nonnull, readonly) NSString *event_id;

/**
 当前页面信息
 */
@property (nonatomic, nonnull, readonly) NSString *current_info;

/**
 App版本号
 */
@property (nonatomic, nonnull) NSString *app_version;


/**
 网络请求会话ID
 */
@property (nonatomic, nonnull) NSString *client_id;


/**
 用户ID
 @discussion 该值为合成值，依赖userID和手机号
 @note 该值大多为数据库中的memberID
 */
@property (nonatomic, nonnull) NSString *user_id;

/**
 城市ID
 */
@property (nonatomic, nonnull) NSString *device_city_id;

/**
 将事件转换为字典
 
 @return 事件数据
 */
- (nonnull NSDictionary *)convertSelfToDict;

@end

/**
 设备信息
 */
@interface UCARMonitorOldStoreDevice : UCARMonitorOldStoreCommonInfo

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
 系统版本
 */
@property (nonatomic, nonnull, readonly) NSString *device_sys_version;

/**
 网络类型（2G/3G/4G）
 */
@property (nonatomic, nonnull, readonly) NSString *device_net_type;

/**
 运营商（联通、电信）
 */
@property (nonatomic, nonnull, readonly) NSString *device_mobile_operator;

/**
 手机状态（是否root、越狱）
 */
@property (nonatomic, nonnull, readonly) NSString *device_device_status;

/**
 分辨率
 */
@property (nonatomic, nonnull, readonly) NSString *device_screen_resolution;

/**
 事件时间
 */
@property (nonatomic, nonnull, readonly) NSString *device_time;

/**
 扩展信息
 */
@property (nonatomic, nonnull) NSString *device_remark;

/**
 App版本号
 */
@property (nonatomic, nonnull) NSString *device_app_version;

@end


/**
 Event事件
 */
@interface UCARMonitorOldStoreEvent : UCARMonitorOldStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;

/**
 事件时间
 */
@property (nonatomic, nonnull, readonly) NSString *event_event_time;

/**
 订单号
 @note 为保持与新表统一，该值归入remark，不在单独统计
 */
@property (nonatomic, nonnull, readonly) NSString *event_order_id;

/**
 事件编码
 */
@property (nonatomic, nonnull) NSString *event_event_code;

/**
 扩展信息
 */
@property (nonatomic, nonnull) NSString *event_event_remark;

@end

/**
 页面事件
 */
@interface UCARMonitorOldStoreRoute : UCARMonitorOldStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;

/**
 该值不统计
 */
@property (nonatomic, nonnull, readonly) NSString *route_widget_code;

/**
 事件时间
 */
@property (nonatomic, nonnull, readonly) NSString *route_time;

/**
 扩展信息
 */
@property (nonatomic, nonnull) NSString *route_remark;

/**
 页面编码
 */
@property (nonatomic, nonnull) NSString *route_activity_code;

/**
 进入(into)/离开(leave)
 */
@property (nonatomic, nonnull) NSString *route_event;

@end

/**
 DNS信息
 */
@interface UCARMonitorOldStoreDNS : UCARMonitorOldStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;

/**
 司机端/客户端
 */
@property (nonatomic, nonnull, readonly) NSString *dns_user_type;

/**
 poi信息
 @note 搜集难度较高，不使用
 */
@property (nonatomic, nonnull, readonly) NSString *dns_poi;

/**
 事件时间
 */
@property (nonatomic, nonnull, readonly) NSString *dns_time;

/**
 域名
 */
@property (nonatomic, nonnull) NSString *device_domain;

/**
 IP
 */
@property (nonatomic, nonnull) NSString *dns_ip;

/**
 用户ID
 @discussion 该值为合成值，依赖userID和手机号
 @note 该值大多为数据库中的memberID
 */
@property (nonatomic, nonnull) NSString *dns_user_id;


/**
 城市ID
 */
@property (nonatomic, nonnull) NSString *dns_city_id;


/**
 App版本号
 */
@property (nonatomic, nonnull) NSString *dns_app_version;

@end

/**
 异常事件
 */
@interface UCARMonitorOldStoreException : UCARMonitorOldStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;

/**
 事件时间
 */
@property (nonatomic, nonnull, readonly) NSString *exception_time;

/**
 异常编码
 */
@property (nonatomic, nonnull) NSString *exception_code;

/**
 异常堆栈信息
 */
@property (nonatomic, nonnull) NSString *exception_stack;

/**
 扩展信息
 */
@property (nonatomic, nonnull) NSString *exception_remark;

@end

/**
 日志信息
 */
@interface UCARMonitorOldStoreLog : UCARMonitorOldStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;

/**
 事件时间
 */
@property (nonatomic, nonnull, readonly) NSString *log_time;

/**
 日志标签
 */
@property (nonatomic, nonnull) NSString *log_tag;

/**
 日志内容
 */
@property (nonatomic, nonnull) NSString *log_content;

@end

/**
 反作弊数据验证
 
 @note http://wiki.10101111.com/pages/viewpage.action?pageId=192393215
 hbase数据表 表名: t_scd_new_device_monitor_driverCheating
 */
@interface UCARMonitorOldStoreDriverCheating : UCARMonitorOldStoreCommonInfo

/**
 事件类型
 */
@property (nonatomic, nonnull, readonly) NSString *type;

/**
 应用类型类型
 */
@property (nonatomic, nonnull, readonly) NSString *app_name;

/**
 订单ID
 */
@property (nonatomic, copy) NSString *orderID;

/**
 订单号
 */
@property (nonatomic, copy) NSString *orderNO;

/**
 司机ID
*/
// @property (nonatomic, copy) NSString *user_id;

/**
 司机手机
 */
@property (nonatomic, copy) NSString *userMobile;

/**
 用户ID
 */
@property (nonatomic, copy) NSString *passengerID;

/**
 用户手机
 */
@property (nonatomic, copy) NSString *passengerMobile;

/**
 订单城市
 */
@property (nonatomic, copy) NSString *orderCityID;

/**
 司机服务城市
 */
@property (nonatomic, copy) NSString *serviceCityID;

/**
 综合评估（按权重聚合核心算法、AI、Flink评估）
 */
@property (nonatomic, strong) NSNumber *grade;

/**
 综合评估明细说明（维度下钻）
 */
@property (nonatomic, strong) NSDictionary *gradeDetail;

/**
 核心算法评估
 */
@property (nonatomic, strong) NSNumber *coreGrade;

/**
 核心算法明细说明（维度下钻）
 */
@property (nonatomic, strong) NSDictionary *coreDetail;

/**
 AI算法评估
 */
@property (nonatomic, strong) NSNumber *aiGrade;

/**
 AI算法明细说明（维度下钻）
 */
@property (nonatomic, strong) NSDictionary *aiDetail;

/**
 实时计算评估
 */
@property (nonatomic, strong) NSNumber *flinkGrade;

/**
 实时计算明细说明（维度下钻）
 */
@property (nonatomic, strong) NSDictionary *flinkDetail;

/**
 App运行环境
 */
@property (nonatomic, strong) NSDictionary *runEnv;

/**
 司机行为
 */
@property (nonatomic, strong) NSDictionary *driverAction;

/**
 司机点击订单结束时间戳
 */
@property (nonatomic, copy) NSString *orderFinishedST;

/**
 备注
 */
@property (nonatomic, strong) NSDictionary *remark;

@end
