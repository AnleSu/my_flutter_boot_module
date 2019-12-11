//
//  UCARMAPIHttpConfig.h
//  Pods
//
//  Created by linux on 2017/7/25.
//
//

#import "UCARHttpBaseConfig.h"

/**
 MAPI请求配置
 */
@interface UCARMAPIHttpConfig : UCARHttpBaseConfig

#ifdef DEBUG

/**
 内部调试开关

 */
@property (nonatomic) BOOL internalDebug;

#endif

/**
 密钥
 */
@property (nonatomic, strong, nonnull) NSString *APISecretKey;

/**
 cid
 */
@property (nonatomic, strong, nonnull) NSString *cid;

/**
 特殊接口兼容，仅用于YY项目
 @note 其他项目严禁设置
 */
@property (nonatomic, strong, nullable) NSString *customCid;

/**
 App版本号，仅用于司机端项目
 @note 其他项目严禁设置
 */
@property (nonatomic, copy) NSString *appVersion;

/**
 是否允许block请求，目前仅用于refreshKey, default = YES
 @note 如果不想请求被缓存，可设置此值
 */
@property (nonatomic) BOOL allowCache;

/**
 标记 refreshKey 请求，业务层不要使用此值
 */
@property (nonatomic) BOOL refreshKeyRequest;

/**
 自动处理业务错误，处理逻辑为显示错误提示，default = YES
 @note 此值仅针对code=7，对其余code无效，手动处理错误时需先判定code==7
 */
@property (nonatomic, assign) BOOL autoDealMAPIError;

/**
 自定义错误逻辑，default = NO
 @note 此值对所有 MAPIError 错误有效, 优先级最高
 */
@property (nonatomic, assign) BOOL customDealMAPIError;


/**
 自动处理网络错误，处理逻辑为显示错误提示，default = YES
 */
@property (nonatomic, assign) BOOL autoDealNetworkError;

/**
 用于保存原始参数，此值用于打印原始参数
 @note 这是内部属性，若无需封装参数，可直接设置该值为 parameters
 */
@property (nonatomic, nullable) NSDictionary *originParameters;

@end
