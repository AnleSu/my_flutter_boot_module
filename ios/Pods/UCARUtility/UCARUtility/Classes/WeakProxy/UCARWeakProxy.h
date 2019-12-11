//
//  UCARWeakProxy.h
//  Pods
//
//  Created by limeng on 17/1/25.
//
//

#import <Foundation/Foundation.h>

/**
 A proxy used to hold a weak object.
 It can be used to avoid retain cycles, such as the target in NSTimer or
 CADisplayLink.
 */

@interface UCARWeakProxy : NSProxy

/**
 The proxy target.
 */
@property (nonatomic, weak, readonly) id target;

/**
 Creates a new weak proxy for target.

 @param target Target object.

 @return A new proxy object.
 */
+ (instancetype)proxyWithTarget:(id)target;

@end
