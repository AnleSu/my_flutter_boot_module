//
//  UIViewController+UCARMonitor.m
//  UCARMonitor
//
//  Created by linux on 2018/7/11.
//

#import "UCARMonitorStore.h"
#import "UIViewController+UCARMonitor.h"
#import <objc/runtime.h>

@implementation UIViewController (UCARMonitor)

static const char UCARMonitor_VCLoadTimeKey = '\0';
- (void)setUCARMonitor_VCLoadTime:(NSNumber *)UCARMonitor_VCLoadTime {
    if (UCARMonitor_VCLoadTime != self.UCARMonitor_VCLoadTime) {
        // 存储新的
        [self willChangeValueForKey:@"UCARMonitor_VCLoadTime"]; // KVO
        objc_setAssociatedObject(self, &UCARMonitor_VCLoadTimeKey, UCARMonitor_VCLoadTime,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@"UCARMonitor_VCLoadTime"]; // KVO
    }
}

- (NSNumber *)UCARMonitor_VCLoadTime {
    return objc_getAssociatedObject(self, &UCARMonitor_VCLoadTimeKey);
}

static const char UCARMonitor_VCHasLoadedKey = '\0';
- (void)setUCARMonitor_VCHasLoaded:(NSNumber *)UCARMonitor_VCHasLoaded {
    if (UCARMonitor_VCHasLoaded != self.UCARMonitor_VCHasLoaded) {
        // 存储新的
        [self willChangeValueForKey:@"UCARMonitor_VCHasLoaded"]; // KVO
        objc_setAssociatedObject(self, &UCARMonitor_VCHasLoadedKey, UCARMonitor_VCHasLoaded,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@"UCARMonitor_VCHasLoaded"]; // KVO
    }
}

- (NSNumber *)UCARMonitor_VCHasLoaded {
    return objc_getAssociatedObject(self, &UCARMonitor_VCHasLoadedKey);
}

static const char UCARMonitor_VCAppearTimeKey = '\0';
- (void)setUCARMonitor_VCAppearTime:(NSNumber *)UCARMonitor_VCAppearTime {
    if (UCARMonitor_VCAppearTime != self.UCARMonitor_VCAppearTime) {
        // 存储新的
        [self willChangeValueForKey:@"UCARMonitor_VCAppearTime"]; // KVO
        objc_setAssociatedObject(self, &UCARMonitor_VCAppearTimeKey, UCARMonitor_VCAppearTime,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@"UCARMonitor_VCAppearTime"]; // KVO
    }
}

- (NSNumber *)UCARMonitor_VCAppearTime {
    return objc_getAssociatedObject(self, &UCARMonitor_VCAppearTimeKey);
}

- (void)UCARMonitor_viewDidLoad {
    self.UCARMonitor_VCLoadTime = @(CACurrentMediaTime());
    self.UCARMonitor_VCHasLoaded = @(NO);
    
    [UCARMonitorStore sharedStore].pageStuckMonitored = NO;
    
    NSDictionary *remark = @{@"page" : NSStringFromClass(self.class)};
    [[UCARMonitorStore sharedStore] storeEvent:@"viewDidLoad" remark:remark];
}

- (void)UCARMonitor_viewWillAppear {
    [[UCARMonitorStore sharedStore] storeRoute:NSStringFromClass(self.class)
                                        action:UCARMonitorStoreRouteActionInto
                                        remark:@{@"timestamp":@(CACurrentMediaTime()).stringValue}];

    self.UCARMonitor_VCAppearTime = @(CACurrentMediaTime());
}

- (void)UCARMonitor_viewDidAppear {
    if (!self.UCARMonitor_VCHasLoaded.boolValue) {
        self.UCARMonitor_VCHasLoaded = @(YES);
        CFTimeInterval VCLoadedTime = CACurrentMediaTime();
        CFTimeInterval VCLoadTime = self.UCARMonitor_VCLoadTime.doubleValue;
        CFTimeInterval duration = VCLoadedTime - VCLoadTime;
        NSInteger durationMS = floor(duration * 1000);
        NSDictionary *remark = @{@"duration" : @(durationMS),
                                 @"page" : NSStringFromClass(self.class),
                                 @"startTime": self.UCARMonitor_VCLoadTime.stringValue,
                                 @"endTime": @(VCLoadedTime).stringValue};
        [[UCARMonitorStore sharedStore] storeEvent:@"pageRender" remark:remark];
    }
}

- (void)UCARMonitor_viewWillDisappear {
    [[UCARMonitorStore sharedStore] storeRoute:NSStringFromClass(self.class)
                                        action:UCARMonitorStoreRouteActionLeave
                                        remark:@{@"timestamp":@(CACurrentMediaTime()).stringValue}];

    CFTimeInterval VCDisappearTime = CACurrentMediaTime();
    CFTimeInterval VCAppearTime = self.UCARMonitor_VCAppearTime.doubleValue;
    CFTimeInterval duration = VCDisappearTime - VCAppearTime;
    NSInteger durationMS = floor(duration * 1000);
    NSDictionary *remark = @{@"duration" : @(durationMS), @"page" : NSStringFromClass(self.class)};
    [[UCARMonitorStore sharedStore] storeEvent:@"pageDuration" remark:remark];
}

@end
