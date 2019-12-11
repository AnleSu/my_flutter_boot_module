//
//  UCarLiveNetManager.h
//  UCarLive
//
//  Created by huyujin on 16/10/11.
//  Copyright © 2016年 UCarInc. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, UCARFaceIdErrorTpye) {
    UCARFaceIdErrorGeneral = -1,//一般失败
    UCARFaceIdErrorSerious = -2,//严重失败
    UCARFaceIdErrorOtherCode = -3,//未知code错误
    UCARFaceIdErrorAnalysis = -4,//解析失败
    UCARFaceIdErrorHttpRequest = -100, //网络请求错误
    UCARFaceIdSuccess = 1//成功
};


@interface UCarLiveNetManager : NSObject

+ (instancetype)sharedInstance;


- (void)requestPostWithURL:(NSString*)urlStr
                    params:(NSDictionary*)params
                   success:(void(^)(int code, NSDictionary* info))success
                   failure:(void(^)(int code, NSString* msg))failure;


- (void)requestPostWithURL:(NSString*)urlStr
                    params:(NSDictionary*)params
                     files:(NSDictionary *)files
                   success:(void(^)(int code, NSDictionary* info))success
                   failure:(void(^)(int code, NSString* msg))failure;

@end
