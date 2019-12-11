//
//  UCARHttpBaseManager.h
//  UCar
//
//  Created by KouArlen on 16/3/7.
//  Copyright © 2016年 zuche. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Foundation/Foundation.h>
//此处引入常量，避免每次使用网络库时都要引用常量头文件
#import "UCARHttpBaseConfig.h"
#import "UCARHttpBaseConstants.h"

/**
 DNS检查完成回调

 @param DNSHijacked 是否被劫持
 @param IPs DNS服务器返回的IP
 @param error 错误
 */
typedef void (^UCARDNSCheckFinishBlock)(BOOL DNSHijacked, NSArray<NSString *> *_Nonnull IPs, NSError *_Nullable error);

/**
 请求成功callback

 @param response 服务器返回的完整数据
 @param request 请求的参数
 */
typedef void (^UCARHttpSuccessBlock)(id _Nonnull response, NSDictionary *_Nullable request);

/**
 请求失败callback，包含网络错误和业务错误。判断业务失败还是网络错误的关键在于error，业务失败的domain在UCARHttpConstants.h中有声明，可以此来进行判断。

 @param response 服务器返回的完整数据
 @param request 请求的参数
 @param error 网络错误或者序列化错误
 */
typedef void (^UCARHttpFailureBlock)(id _Nullable response, NSDictionary *_Nullable request, NSError *_Nonnull error);

@class UCARSecurityPolicy;

/**
 基础请求manager
 */
@interface UCARHttpBaseManager : NSObject

/**
 AFN sessionManager，请求将通过该实例发送
 */
@property (nonatomic, readonly, nonnull) AFHTTPSessionManager *httpQueueManager;

/**
 JSON序列化工具，自动移除json中的null值
 */
@property (nonatomic, readonly, nonnull) AFJSONResponseSerializer *jsonSerializer;

/**
 安全策略，主要用于 httpdns 功能
 */
@property (nonatomic, readonly, nonnull) UCARSecurityPolicy *securityPolicy;

/**
 网络连通状态
 @note 如果你需要监测网络状态变化，可注册AFN通知事件AFNetworkingReachabilityDidChangeNotification，不建议通过KVO监测该值
 */
@property (nonatomic, readonly) BOOL isReachable;

/**
 网络状态描述
 */
@property (nonatomic, readonly, nonnull) NSString *networkStatus;

/**
 sharedManager

 @return a shared instance
 */
+ (nonnull instancetype)sharedManager;

/**
 获取包含在 UCARNetwork.bundle 中的资源文件

 @param resource 资源名
 @param type 资源类型
 @return 资源文件路径
 */
- (nullable NSString *)pathForResource:(nonnull NSString *)resource ofType:(nonnull NSString *)type;

/**
 解密 response 数据

 @param responseData response数据
 @param config 请求配置
 @param httpError 错误
 @return 解密后的json数据
 */
- (nullable NSDictionary *)decryptData:(nonnull NSData *)responseData
                            withConfig:(nonnull UCARHttpBaseConfig *)config
                                 error:(NSError *_Nullable *_Nullable)httpError;

/**
 设置 domain 和 IP 的映射

 @param domain 域名
 @param IP ip
 */
- (void)setDomain:(nonnull NSString *)domain andIP:(nonnull NSString *)IP;

/**
 获取请求的完整链接

 @param config 请求配置
 @return url for this config
 */
- (nonnull NSString *)fullURLForConfig:(nonnull UCARHttpBaseConfig *)config;

/**
 发送异步请求并返回task

 @param config 请求配置
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @return request task
 @note 返回值是可能为nil的
 */
- (nullable NSURLSessionDataTask *)asyncHttpWithConfig:(nonnull UCARHttpBaseConfig *)config
                                               success:(nonnull UCARHttpSuccessBlock)successBlock
                                               failure:(nonnull UCARHttpFailureBlock)failureBlock;

/**
 下载文件

 @param fileURL 文件链接
 @param path 存储路径
 @param completionHandler 下载完成回调
 @note the completionHandler will run in back queue
 */
- (void)downloadFileFromURLString:(nonnull NSString *)fileURL
                           toPath:(nonnull NSString *)path
                completionHandler:(nonnull void (^)(NSURLResponse *_Nullable response, NSURL *_Nullable filePath,
                                                    NSError *_Nullable error))completionHandler;

/**
 检查域名是否被劫持

 @param domain domain
 @param realIP 真实IP，由API接口返回
 @param finishBlock 完成回调
 @note 必须在主线程调用；传入的参数可携带端口号，支持IPv6地址；DNSHijacked默认返回YES，注意检测error确认是否发生错误
 */
- (void)checkDNSHijackForDomain:(nonnull NSString *)domain
                     withRealIP:(nonnull NSString *)realIP
                    finishBlock:(nonnull UCARDNSCheckFinishBlock)finishBlock;

#ifdef DEBUG

/**
 推送日志到实时日志服务

 @param domain 域名信息
 @param subURL url path
 @param request 请求参数
 @param response 请求响应
 @param errorStr 错误描述
 @param realTimeLogID 日志ID
 */
- (void)postLog:(nonnull NSString *)domain
           subURL:(nonnull NSString *)subURL
          request:(nonnull NSDictionary *)request
         response:(nonnull NSDictionary *)response
            error:(nonnull NSString *)errorStr
    realTimeLogID:(nonnull NSString *)realTimeLogID;
#endif

@end
