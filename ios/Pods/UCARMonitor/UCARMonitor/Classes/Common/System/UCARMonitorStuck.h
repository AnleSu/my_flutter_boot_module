//
//  UCARMonitorStuck.h
//  UCARMonitor
//
//  Created by linux on 2018/7/16.
//

#import <Foundation/Foundation.h>


/**
 卡顿监控
 @discussion https://github.com/suifengqjn/PerformanceMonitor
 */
@interface UCARMonitorStuck : NSObject


/**
 开始监控
 */
- (void)startMonitor;


/**
 停止监控
 */
- (void)stopMonitor;

@end
