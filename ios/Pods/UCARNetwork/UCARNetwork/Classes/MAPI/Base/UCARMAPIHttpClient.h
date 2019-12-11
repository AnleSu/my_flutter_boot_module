//
//  UCARMAPIHttpClient.h
//  Pods
//
//  Created by linux on 2017/7/26.
//
//

#import "UCARHttpBaseManager.h"
#import "UCARMAPIHttpConfig.h"
#import "UCARMAPIHttpProtocol.h"
#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *_Nonnull ucar_wtfmapi(void);
FOUNDATION_EXPORT NSString *const UCARURLPCARRefreshKey;

/**
 需要在UCAREventIDGenerator，UCARMonitor之后初始化
 @note 此类为虚类，不要直接使用。
 */
@interface UCARMAPIHttpClient : NSObject

/**
 相关数据存储位置，在子类的 commonInit 中设置
 */
@property (nonatomic, nonnull) NSUserDefaults *storeUserDefaults;

/**
 域名信息存储时的 key 值，在子类的 commonInit 中设置
 */
@property (nonatomic, nullable) NSString *domainInfoStoreKey;

/**
 session 信息存储时的 key 值，在子类的 commonInit 中设置
 */
@property (nonatomic, nullable) NSString *sessionIDStoreKey;

/**
 APISecretKey 存储时的 key 值，在子类的 commonInit 中设置
 */
@property (nonatomic, nullable) NSString *APISecretKeyStoreKey;

/**
 APISecretKey 的明文存储时的 key 值，在子类的 commonInit 中设置
 */
@property (nonatomic, nullable) NSString *APISecretKeyPlainTextStoreKey;
/**
 APISecretKey 的密文存储时的 key 值，在子类的 commonInit 中设置
 */
@property (nonatomic, nullable) NSString *APISecretKeyEncryptedStoreKey;

/**
 hosturl 接口返回值中 mapi 域名的 key 值，在子类的 commonInit 中设置
 */
@property (nonatomic, nullable) NSString *httpDNSDomainParseKey;

/**
 api域名，请求时会以此值去设置 config 中的 domain
 */
@property (nonatomic, nonnull) NSString *APIDomain;

/**
 cid，标明 api 编号和 api 版本
 */
@property (nonatomic, nonnull) NSString *cid;

/**
 域名信息，包含 domain 和 ip
 */
@property (nonatomic, nullable) NSDictionary *domainInfo;

/**
 sessionID 与后台的会话标记
 */
@property (nonatomic, nonnull) NSString *APISessionID;

/**
 上传密钥的重试次数，目前为3次
 */
@property (nonatomic) int MAPIUploadKeyRetryCount;

/**
 密钥是否初始化，用于一个 app 有多个 httpClient 时，解决密钥同步问题。
 */
@property (nonatomic) BOOL refreshKeyInited;

/**
 协商后的密钥
 @note 此值在密钥协商阶段有可能变化，依赖后台动态密钥的开关
 */
@property (nonatomic, nullable) NSString *APISecretKey;

/**
 静态密钥，固定值
 @note 若动态密钥协商次数超过 MAPIUploadKeyRetryCount ，则改为静态密钥协商
 */
@property (nonatomic, nonnull) NSString *staticAPISecretKey;

/**
 密钥明文
 @note 此明文与APISecretKey不同，当使用静态密钥时，APISecretKeyPlainText !=
 APISecretKey
 */
@property (nonatomic, nullable) NSString *APISecretKeyPlainText;

/**
 密钥密文
 */
@property (nonatomic, nullable) NSString *APISecretKeyEncrypted;

/**
 MAPI是否可用

 @note 是否可用的依据为密钥协商是否成功
 */
@property (nonatomic) BOOL MAPIReady;

/**
 调用 refreshKey 的时间
 @note 此值用于限制 refreshKey 调用频率，目前为10s内允许一次调用
 */
@property (nonatomic) NSTimeInterval refreshKeyTime;

/**
 请求结果的代理，用于反馈每个请求的结果，便于 app 统一处理
 */
@property (nonatomic, weak, nullable) id<UCARMAPIHttpProtocol> requestDelegate;

/**
 called in init
 @note 用于设置一些初始化时(其他api调用之前)需要设置的值
 */
- (void)commonInit;

/**
 缓存 refreshKey 成功前的请求

 @param config 请求配置
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)addPrivateRequestWithWithConfig:(nonnull UCARMAPIHttpConfig *)config
                                success:(nonnull UCARHttpSuccessBlock)successBlock
                                failure:(nonnull UCARHttpFailureBlock)failureBlock;

/**
 执行当前缓存的所有请求
 */
- (void)runPrivateRequests;

/**
 封装参数，将原始参数封装为后台对应格式

 @param config 请求配置
 @return 封装后的参数
 */
- (nonnull NSDictionary *)reviseMAPIParametersForConfig:(nonnull UCARMAPIHttpConfig *)config;

/**
 历史遗留问题，京东支付/易联支付专用

 @param config 请求配置
 @return 返回一个封装后的 NSURLRequest，其 URL 为真实请求的URL
 */
- (nullable NSURLRequest *)fullGetURLRequestForConfig:(nonnull UCARMAPIHttpConfig *)config;

/**
 异步 http 请求

 @param config 请求配置
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @return 返回一个 dataTask，一般不用关注，有取消需求是可使用
 */
- (nullable NSURLSessionDataTask *)asyncHttpWithConfig:(nonnull UCARMAPIHttpConfig *)config
                                               success:(nonnull UCARHttpSuccessBlock)successBlock
                                               failure:(nonnull UCARHttpFailureBlock)failureBlock;

/**
 初始化域名信息，一般在 commonInit 最后调用

 @param storeKey domainKey
 */
- (void)initDomainInfoWithStoreKey:(nonnull NSString *)storeKey;

/**
 更新域名信息，当使用 httpdns 技术时使用
 */
- (void)updateMAPIDomainAndIP;

/**
 刷新密钥

 @param init 是否为init调用，初始化时为YES，密钥过期时为NO
 */
- (void)refreshKey:(BOOL)init;

/**
 刷新密钥

 @param config 请求配置
 @note 此接口用于UCARApp特殊需求
 */
- (void)refreshKeyWithConfig:(nonnull UCARMAPIHttpConfig *)config;

/**
 记录错误信息至monitor

 @param config 请求配置
 @param response 响应数据
 @param error 错误信息
 */
- (void)monitorFailureWithConfig:(nonnull UCARMAPIHttpConfig *)config
                        response:(nonnull NSDictionary *)response
                           error:(nonnull NSError *)error;

#ifdef DEBUG

/**
 获取实时日志标记
 @note 该值用于网页端查看日志，与网页端值保持一致即可，一般采用手机号
 */
@property (nonatomic, nonnull, copy) NSString * (^getRealTimeLogIDBlock)(void);
#endif

@end
