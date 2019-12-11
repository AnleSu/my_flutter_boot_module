//
//  BSBacktraceLogger.h
//  BSBacktraceLogger
//
//  Created by 张星宇 on 16/8/27.
//  Copyright © 2016年 bestswifter. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UCARLOG NSLog(@"%@",[UCARBacktraceLogger bs_backtraceOfCurrentThread]);
#define UCARLOG_MAIN NSLog(@"%@",[UCARBacktraceLogger bs_backtraceOfMainThread]);
#define UCARLOG_ALL NSLog(@"%@",[UCARBacktraceLogger bs_backtraceOfAllThread]);

@interface UCARBacktraceLogger : NSObject

+ (NSString *)bs_backtraceOfAllThread;
+ (NSString *)bs_backtraceOfCurrentThread;
+ (NSString *)bs_backtraceOfMainThread;
+ (NSString *)bs_backtraceOfNSThread:(NSThread *)thread;

@end
