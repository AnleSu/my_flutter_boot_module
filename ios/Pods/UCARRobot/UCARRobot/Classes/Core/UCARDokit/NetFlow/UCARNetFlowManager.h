//
//  UCARNetFlowManager.h
//  AFNetworking
//
//  Created by suzhiqiu on 2019/7/24.
//

#import <Foundation/Foundation.h>

typedef NSDictionary * _Nonnull (^DecryptBlock)(NSDictionary * _Nullable  data);


NS_ASSUME_NONNULL_BEGIN

@interface UCARNetFlowManager : NSObject


@property (nonatomic, copy) DecryptBlock decryptBlock;


/**
 单例
 */
+ (UCARNetFlowManager *)shareManager;

/**
 解密conent的加密字段

 @param responseData 响应数据
 @return 解密后的内容
 */
- (NSString *)decryptConent:(NSData *)responseData;

@end

NS_ASSUME_NONNULL_END
