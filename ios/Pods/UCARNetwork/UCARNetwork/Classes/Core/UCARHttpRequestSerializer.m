//
//  UCARHttpRequestSerializer.m
//  UCar
//
//  Created by KouArlen on 15/10/29.
//  Copyright © 2015年 zuche. All rights reserved.
//

#import "UCARHttpRequestSerializer.h"
#import "UCARHttpBaseConstants.h"

@interface UCARHttpRequestSerializer ()

@end

@implementation UCARHttpRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                     error:(NSError *__autoreleasing *)error {
    //修正参数
    NSDictionary *header = parameters[UCARHttpRequestHeader];
    if (header) {
        [parameters removeObjectForKey:UCARHttpRequestHeader];
    }

    NSMutableURLRequest *request = [super requestWithMethod:method
                                                  URLString:URLString
                                                 parameters:parameters
                                                      error:error];

    if (header) {
        [header enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }

    return request;
}

- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                              URLString:(NSString *)URLString
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                                                  error:(NSError *__autoreleasing *)error {
    // HttpBody与HttpBodySteam为互斥关系
    //按照标准用法，应该将参数拼入流中，但因后台解析参数时并未考虑从流中解析，
    //所以需要将参数拼入query中。
    NSMutableURLRequest *mutableRequest = [self requestWithMethod:@"GET"
                                                        URLString:URLString
                                                       parameters:parameters
                                                            error:error];

    return [super multipartFormRequestWithMethod:method
                                       URLString:mutableRequest.URL.absoluteString
                                      parameters:nil
                       constructingBodyWithBlock:block
                                           error:error];
}

//=========================

@end
