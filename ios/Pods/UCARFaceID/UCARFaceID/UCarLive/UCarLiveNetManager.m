//
//  UCarLiveNetManager.m
//  UCarLive
//
//  Created by huyujin on 16/10/11.
//  Copyright © 2016年 UCarInc. All rights reserved.
//

#import "UCarLiveNetManager.h"
#import "UCarLiveEncryption.h"
#import <UIKit/UIKit.h>
#import "MGBaseKit.h"

//#import <objc/runtime.h>

//#define UCarLive_APPID @"fcar"

//#define UCarLive_AESKey @"fcartest"

//#if DEBUG
//#define UCarLive_Base_URL   @"http://fcarufaceidtest.10101111.com/fcarufaceid/api/"
//#else
//#define UCarLive_Base_URL @"http://api.faceid.carbank.cn/fcarufaceid/api/"
//#endif

//#define UCarLive_HOST_URL(url) [NSString stringWithFormat:@"%@%@",UCarLive_Base_URL,url]

#define UCarLive_Debug_URL   @"http://fcarufaceidtest.10101111.com/fcarufaceid/api/"
#define UCarLive_Release_URL @"http://api.faceid.carbank.cn/fcarufaceid/api/"


#define UCarLive_KBoundary @"UCarLive_KBoundary"
#define UCarLive_KNewLine @"\r\n"

@interface UCarLiveNetManager ()

@property (nonatomic, copy) NSString *baseUrl;

@end

@implementation UCarLiveNetManager

+ (instancetype)sharedInstance {
    
    static dispatch_once_t once = 0;
    static UCarLiveNetManager *netManager;
    dispatch_once(&once, ^{
        netManager = [[self alloc] init];
        netManager.baseUrl = [UCarFRService sharedInstance].debugMode ? UCarLive_Debug_URL:UCarLive_Release_URL;
    });
    return netManager;
}

- (void)requestPostWithURL:(NSString*)urlStr
                    params:(NSDictionary*)params
                   success:(void(^)(int code, NSDictionary* info))success
                   failure:(void(^)(int code, NSString* msg))failure;
{
    //添加额外参数
    if (params.count<=0) {params = @{};}
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableDict setObject:urlStr forKey:@"method"];
    
    NSString *tempUrlStr = [self hostUrlWithUrl:urlStr];
    NSURL *url = [NSURL URLWithString:tempUrlStr];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setHTTPBody:[[self buildParams:mutableDict] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode==200) {
            
            NSError *dError = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&dError];
            if(!dError) {
                int code = [jsonDict[@"code"] intValue];
                if (code==1) {
                    NSString *decryString = [UCarLiveEncryption AESForDecry:jsonDict[@"content"] WithKey:[[self class] ucarAppToken]];
                    NSData *decryData = [decryString dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *cError = nil;
                    NSDictionary *contentDict =[NSJSONSerialization JSONObjectWithData:decryData options:NSJSONReadingMutableContainers error:&cError];
                    
                    if (!cError) {
                        success(code,contentDict);
                    }else {
                        failure(-100,[cError localizedDescription]);
                    }
                } else {
                    NSString *msg = jsonDict[@"msg"];
                    failure(-1,msg);
                }
            } else {
                failure(-100,[dError localizedDescription]);
            }
        }else {
            failure(-100,[NSString stringWithFormat:@"httpResponse.statusCode=%ld",(long)httpResponse.statusCode]);
        }

    }];
    [dataTask resume];
}


- (void)requestPostWithURL:(NSString*)urlStr
                    params:(NSDictionary*)params
                     files:(NSDictionary *)files
                   success:(void(^)(int code, NSDictionary* info))success
                   failure:(void(^)(int code, NSString* msg))failure
{
    //添加额外参数
    if (params.count<=0) {params = @{};}
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableDict setObject:urlStr forKey:@"method"];
    
    NSString *tempUrlStr = [self hostUrlWithUrl:urlStr];
    NSURL *url = [NSURL URLWithString:tempUrlStr];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    // 设置请求头信息,告诉服务器这是一个上传请求
    NSString *value  =[NSString stringWithFormat:@"multipart/form-data; boundary=%@",UCarLive_KBoundary];
    [request setValue:value forHTTPHeaderField:@"Content-Type"];
    
    // 拼接文件&非文件参数
    NSData *bodyData = [self buildHTTPBodyWithParams:mutableDict files:files];
    [request setHTTPBody:bodyData];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // 根据会话对象创建uploadTask请求
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode==200) { //网络请求成功返回
            NSError *dError = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&dError];
            if(!dError) {
                int code = [jsonDict[@"code"] intValue];
                if (code==UCARFaceIdSuccess || code == UCARFaceIdErrorGeneral || code == UCARFaceIdErrorSerious) { //业务请求成功
                    if (jsonDict[@"content"]) {
                        NSString *decryString = [UCarLiveEncryption AESForDecry:jsonDict[@"content"] WithKey:[[self class] ucarAppToken]];
                        NSData *decryData = [decryString dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *cError = nil;
                        NSDictionary *contentDict =[NSJSONSerialization JSONObjectWithData:decryData options:NSJSONReadingMutableContainers error:&cError];
                        
                        if (!cError) {
                            success(code,contentDict);
                        }else {
                            failure(UCARFaceIdErrorAnalysis,[cError localizedDescription]);
                        }
                    }else {
                        failure(code,@"content数据为空");
                    }
                    
                }else {
                    failure(UCARFaceIdErrorOtherCode,@"未知code错误");
                }
            } else {
                failure(UCARFaceIdErrorAnalysis,[dError localizedDescription]);
            }
        }else {
            failure(UCARFaceIdErrorHttpRequest,[NSString stringWithFormat:@"statusCode=%ld ",(long)httpResponse.statusCode]);
        }
        
    }];
    
    // 发送请求
    [uploadTask resume];
}



#pragma mark -

- (NSString *)buildParams:(NSDictionary *)params {
    NSString *encryStr = @"";
    if (params.count>0) {
        NSData *qData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        NSString *qStr = [[NSString alloc] initWithData:qData encoding:NSUTF8StringEncoding];
        encryStr = [UCarLiveEncryption AESForEncry:qStr WithKey:[[self class] ucarAppToken]];
    }
    // 获取参数经过加密和编码后的params
    NSString *paramsStr = [NSString stringWithFormat:@"appid=%@&q=%@",[[self class] ucarAppId],encryStr];
    
    return paramsStr;
}

- (NSData *)buildHTTPBodyWithParams:(NSDictionary *)params files:(NSDictionary *)files {
    
    NSMutableData *bodyData = [NSMutableData data];
    
    //q=
    NSString *encryStr = @"";
    if (params.count>0) {
        NSData *qData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        NSString *qStr = [[NSString alloc] initWithData:qData encoding:NSUTF8StringEncoding];
        encryStr = [UCarLiveEncryption AESForEncry:qStr WithKey:[[self class] ucarAppToken]];
    }
    [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", UCarLive_KBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"q"] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"%@\r\n", encryStr] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //appid =
    
    [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", UCarLive_KBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"appid"] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"%@\r\n", [[self class] ucarAppId]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [files enumerateKeysAndObjectsUsingBlock:^(NSString *key, UIImage *obj, BOOL * _Nonnull stop) {
        NSData *imageData = UIImageJPEGRepresentation(obj, 1);
        
        [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", UCarLive_KBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", key,key] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:imageData];
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
    }];
    
    //Close off the request with the boundary
    [bodyData appendData:[[NSString stringWithFormat:@"--%@--\r\n", UCarLive_KBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return bodyData;
    
}


#pragma mark - 

+ (NSString *)ucarAppId {
    UCarFRService *ucarFRService = [UCarFRService sharedInstance];
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//    NSString *appId = [ucarFRService performSelector:@selector(appId)];
//#pragma clang diagnostic pop
    
    return ucarFRService.appId;
}

+ (NSString *)ucarAppToken {
    UCarFRService *ucarFRService = [UCarFRService sharedInstance];
    
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//    NSString *appToken = [ucarFRService performSelector:@selector(appToken)];
//#pragma clang diagnostic pop
    return ucarFRService.appToken;
}

- (NSString *)hostUrlWithUrl:(NSString *)urlStr {
    return [NSString stringWithFormat:@"%@%@",self.baseUrl,urlStr];
}

@end
