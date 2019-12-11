//
//  UCARNetFlowManager.m
//  AFNetworking
//
//  Created by suzhiqiu on 2019/7/24.
//

#import "UCARNetFlowManager.h"
#import "DoraemonUrlUtil.h"

@implementation UCARNetFlowManager

//单例
+ (UCARNetFlowManager *)shareManager {
    static UCARNetFlowManager *sharedManager= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[UCARNetFlowManager alloc] init];
    });
    return sharedManager;
}

// 解密conent的加密字段
- (NSString *)decryptConent:(NSData *)responseData {
    if (!self.decryptBlock) { //没有使用接口直接JSON返回
       return  [DoraemonUrlUtil convertJsonFromData:responseData];
    }
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
    if (!responseDic) {
        return @"";
    }
    NSDictionary *decryptDic = self.decryptBlock(responseDic);
    if (!decryptDic) {
        return @"";
    }
    NSString *responseBody = @"";
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:decryptDic options:NSJSONWritingPrettyPrinted error:&parseError];
    if (!parseError && jsonData) {
        responseBody = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return responseBody;
}


@end
