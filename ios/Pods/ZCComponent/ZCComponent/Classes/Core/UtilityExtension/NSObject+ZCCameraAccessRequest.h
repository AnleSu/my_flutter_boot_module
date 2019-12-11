//
//  NSObject+ZCCameraAccessRequest.h
//  Pods
//
//  Created by ZhangYuqing on 2019/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^requestAccessSuccess)();

@interface NSObject (ZCCameraAccessRequest)
/**
 请求相机权限
 */
+ (void)grantToCamera:(requestAccessSuccess)successBlock;
@end

NS_ASSUME_NONNULL_END
