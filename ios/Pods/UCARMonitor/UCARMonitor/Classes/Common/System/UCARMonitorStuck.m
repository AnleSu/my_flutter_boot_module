//
//  UCARMonitorStuck.m
//  UCARMonitor
//
//  Created by linux on 2018/7/16.
//

#import "UCARMonitorStuck.h"
//#import <KSCrash/KSCrash.h>
#import "UCARMonitorStore.h"
#import <UCARLogger/UCARLogger.h>

@interface UCARMonitorStuck ()

@property (nonatomic) int timeoutCount;
@property (nonatomic) CFRunLoopObserverRef observer;
@property (nonatomic) dispatch_semaphore_t semaphore;
@property (nonatomic) CFRunLoopActivity activity;

@end

@implementation UCARMonitorStuck

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    UCARMonitorStuck *moniotr = (__bridge UCARMonitorStuck *)info;

    moniotr.activity = activity;

    dispatch_semaphore_t semaphore = moniotr.semaphore;
    dispatch_semaphore_signal(semaphore);
}

- (void)stopMonitor {
    if (!_observer)
        return;
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    _observer = NULL;
}

- (void)startMonitor {
    if (_observer)
        return;

    // 信号,Dispatch Semaphore保证同步
    _semaphore = dispatch_semaphore_create(0);

    // 注册RunLoop状态观察
    CFRunLoopObserverContext context = {0, (__bridge void *)self, NULL, NULL};
    _observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runLoopObserverCallBack,
                                        &context);
    //将观察者添加到主线程runloop的common模式下的观察中
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);

    // 在子线程监控时长 开启一个持续的loop用来进行监控
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (YES) {
            //假定连续5次超时50ms认为卡顿(当然也包含了单次超时250ms)
            long st = dispatch_semaphore_wait(self.semaphore, dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC));
            if (st != 0) {
                if (!self.observer) {
                    self.timeoutCount = 0;
                    self.semaphore = 0;
                    self.activity = 0;
                    return;
                }
                //两个runloop的状态，BeforeSources和AfterWaiting这两个状态区间时间能够检测到是否卡顿
                if (self.activity == kCFRunLoopBeforeSources || self.activity == kCFRunLoopAfterWaiting) {
                    if (++self.timeoutCount < 5)
                        continue;

                    UCARLoggerDebug(@"pageStuck");
                    if (![UCARMonitorStore sharedStore].pageStuckMonitored) {
                        [UCARMonitorStore sharedStore].pageStuckMonitored = YES;
                        //上传服务器
                        //                        [[KSCrash sharedInstance] reportUserException:@"pageStuck"
                        //                        reason:@"pageStuck" language:@"objc" lineOfCode:nil stackTrace:@[]
                        //                        logAllThreads:YES terminateProgram:NO];
                    }
                } // end activity
            }     // end semaphore wait
            self.timeoutCount = 0;
        } // end while
    });
}

@end
