//
//  UCARMAPIHttpProtocol.h
//  Pods
//
//  Created by linux on 2017/7/25.
//
//

#ifndef UCARMAPIHttpProtocol_h
#define UCARMAPIHttpProtocol_h

#import <Foundation/Foundation.h>

@class UCARMAPIHttpConfig;
@class UCARMAPIHttpClient;

/**
 回调，用于通知manager请求结果，用于分析及统计
 */
@protocol UCARMAPIHttpProtocol <NSObject>

@required

/**
 请求成功

 @param config 请求配置
 @param response 请求响应
 */
- (void)requestSuccessWithConfig:(nonnull UCARMAPIHttpConfig *)config response:(nonnull NSDictionary *)response;

/**
 请求失败

 @param config 请求配置
 @param response 请求响应
 @param error 错误
 */
- (void)requestFailureWithConfig:(nonnull UCARMAPIHttpConfig *)config
                        response:(nullable NSDictionary *)response
                           error:(nonnull NSError *)error;

@end

#endif /* UCARMAPIHttpProtocol_h */
