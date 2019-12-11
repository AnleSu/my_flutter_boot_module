//
//  UCAREventIDGenerator.h
//  Pods
//
//  Created by North on 16/8/31.
//
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const UCAREventIDStoreKey;

//

/**
 事件ID
 @discussion
 此处出于效率角度考虑，未做线程安全，可能导致多个生成的id为同一值。故该值对于App而言不具备参考价值。
 */
@interface UCAREventIDGenerator : NSObject


/**
 初始化EventID

 @param eventID 初始值
 @discussion 初始化工作已在UCARNetwork中自动执行
 */
+ (void)initEventID:(long)eventID;


/**
 生成一个eventID

 @return an event id string
 */
+ (NSString *)generateEventID;

@end
