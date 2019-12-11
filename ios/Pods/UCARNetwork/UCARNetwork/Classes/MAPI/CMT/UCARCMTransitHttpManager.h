//
//  UCARCMTransitHttpManager.h
//  CMT
//
//  Created  by hong.zhu on 2019/3/6.
//  Copyright © 2019年 linux. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCARCMTransitHttpClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCARCMTransitHttpManager : NSObject

/**
 api domain
 */
@property (nonatomic, copy, nonnull) NSString *APIDomain;

/**
 cid
 */
@property (nonatomic, strong, nonnull) NSString *cid;

/**
 初始化域名信息
 
 @param groupStoreKey 域名数据在 group nsuserdefaults中的key值
 */
- (void)initDomainInfoWithGroupStoreKey:(nonnull NSString *)groupStoreKey;

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
 refreshKey
 
 @param init 是否为init调用，初始化时为YES，密钥过期时为NO
 */
- (void)refreshKey:(BOOL)init;

@end

NS_ASSUME_NONNULL_END
