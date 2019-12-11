//
//  UCARHttpBaseConfig.h
//  UCar
//
//  Created by linux on 16/3/8.
//  Copyright © 2016年 zuche. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 http method

 - UCARHttpMethodGet: get
 - UCARHttpMethodPost: post
 */
typedef NS_ENUM(NSInteger, UCARHttpMethod) { UCARHttpMethodGet, UCARHttpMethodPost };

@protocol AFMultipartFormData;

/**
 基础配置，用于存储请求信息
 */
@interface UCARHttpBaseConfig : NSObject

/**
 url domain, never contain path
 */
@property (nonatomic) NSString *domain;

/**
 url path
 */
@property (nonatomic) NSString *subURL;

/**
 request param
 */
@property (nonatomic) NSDictionary *parameters;

/**
 whether callback run in back, default = YES
 */
@property (nonatomic) BOOL runInBackQueue;

/**
 http method, get or post, default = UCARHttpMethodGet
 */
@property (nonatomic) UCARHttpMethod httpMethod;

/**
 IP直连，不使用域名，default = YES
 @note 此功能依赖UCARHttpBaseManager中"setDomain: andIP:" 的设置
 */
@property (nonatomic) BOOL httpdnsEnable;

/**
 enable https, default = YES
 */
@property (nonatomic) BOOL httpsEnable;

/**
 eventID, 后台统计使用，自动生成
 */
@property (nonatomic, readonly) NSString *eventID;

/**
 上传数据和文件。上传支持多文件，但是不要将文本数据通过该方式上传。
 具体解释参见UCARHttpRequestSerializer.m
 示例
 [formData appendPartWithFileData:param.data name:@"imageBinarydData"
 fileName:@"img.jpg" mimeType:@"image/jpeg"];
 [formData appendPartWithFileData:param.data name:@"imageBinarydData"
 fileName:@"img.png" mimeType:@"image/png"];
 @note 如果httpMethod != UCARHttpMethodPost, 该值将会被忽略
 */
@property (nonatomic, copy) void (^postDataFormatBlock)(id<AFMultipartFormData> formData);

/**
 自定义的http header，以追加方式添加至 request header，基本只在订单接口使用
 */
@property (nonatomic) NSDictionary *header;

/**
 response是否需要解析，default = YES
 @note 如果为NO，则返回原始NSData
 */
@property (nonatomic) BOOL needParse;

/**
 response是否需要解密, default = NO
 */
@property (nonatomic) BOOL needDecrypt;

/**
 response解密密钥
 @note 只在 needDecrypt=YES 时有效
 */
@property (nonatomic) NSString *decryptKey;

/**
 请求发送时间
 @note 该值由框架自动记录，App无需关注
 */
@property (nonatomic) CFTimeInterval requestSendTime;

/**
 默认配置

 @return a default config instance
 */
+ (instancetype)defaultConfig;

@end
