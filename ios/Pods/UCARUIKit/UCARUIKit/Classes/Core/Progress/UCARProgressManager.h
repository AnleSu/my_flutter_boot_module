//
//  UCARProgressManager.h
//  UCar
//
//  Created by KouArlen on 16/3/18.
//  Copyright © 2016年 zuche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 *  处理Loading && Message
 *  never call this manager out main queue.
 */

@interface UCARProgressManager : NSObject

//==========loading=============
//自1.2.0开始，移除统一loading功能

//==========Tips===============

/**
 no icon

 @param message message
 */
+ (void)showMessage:(NSString*)message;

+ (void)showInfoMessage:(NSString*)message;

+ (void)showSuccessMessage:(NSString*)message;

+ (void)showErrorMessage:(NSString*)message;

+ (void)showMessage:(NSString*)message duration:(NSTimeInterval)duration;

+ (void)showInfoMessage:(NSString*)message duration:(NSTimeInterval)duration;

+ (void)showSuccessMessage:(NSString*)message duration:(NSTimeInterval)duration;

+ (void)showErrorMessage:(NSString*)message duration:(NSTimeInterval)duration;

+ (void)showMessageUseAlert:(NSString *)message;

@end
