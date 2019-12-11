//
//  UCARMonitorStore.m
//  UCARMonitor
//
//  Created by linux on 2018/7/6.
//

#import "UCARMonitorStore.h"
#import "UCARMonitorCPU.h"
#import "UCARMonitorMemory.h"
#import "UCARMonitorNewStore.h"
#import "UCARMonitorOldStore.h"

#import "UCARMonitorStuck.h"
#import "UCARProcessInfo.h"
#import <UCARLogger/UCARLogger.h>

const NSTimeInterval UCARMonitorStoreTimerInterval = 10.0;

@interface UCARMonitorStore ()
//收集cpu及内存占用
@property (nonatomic, strong) NSTimer *systemTimer;

@property (nonatomic, strong) UCARMonitorStuck *fps;

@property (nonatomic, assign) BOOL didLaunched;
@property (nonatomic, assign) BOOL ignoreStartDuration;

@end

@implementation UCARMonitorStore

+ (instancetype)sharedStore {
    static UCARMonitorStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[UCARMonitorStore alloc] init];
    });
    return store;
}

- (void)setSessionID:(NSString *)sessionID {
    _sessionID = [sessionID copy];
    if (_version == UCARMonitorStoreVersionNew) {
        [UCARMonitorNewStore sharedStore].sessionID = sessionID;
    } else {
        [UCARMonitorOldStore sharedStore].sessionID = sessionID;
    }
}

- (void)setFilterPerformance:(BOOL)filterPerformance {
    _filterPerformance = filterPerformance;
    if (filterPerformance) {
        [_systemTimer invalidate];
        _systemTimer = nil;
    } else {
        _systemTimer = [NSTimer scheduledTimerWithTimeInterval:UCARMonitorStoreTimerInterval
                                                        target:self
                                                      selector:@selector(collectSystemInfo)
                                                      userInfo:nil
                                                       repeats:YES];
    }
}

- (UCARMonitorUploader *)uploader
{
    if (_version == UCARMonitorStoreVersionNew) {
        return [UCARMonitorNewStore sharedStore].uploader;
    } else {
        return [UCARMonitorOldStore sharedStore].uploader;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _version = UCARMonitorStoreVersionNew;

        self.filterPerformance = YES;

        //        _fps = [[UCARMonitorStuck alloc] init];
        _didLaunched = NO;
        _ignoreStartDuration = NO;

        _pageStuckMonitored = NO;
    }
    return self;
}

- (void)dealloc {
    [_systemTimer invalidate];
    _systemTimer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)collectSystemInfo {
    float cpu = ucar_cpu_usage();
    uint64_t memory = UCAR_FBMemoryProfilerResidentMemoryInBytes();
    float memoryMB = memory / 1024.0 / 1024.0;
    NSString *cpuStr = [NSString stringWithFormat:@"%0.2f", cpu];
    NSString *memoryStr = [NSString stringWithFormat:@"%0.2f", memoryMB];
    [self storePerformance:@"cpu" remark:@{@"cpu" : cpuStr}];
    [self storePerformance:@"memory" remark:@{@"memory" : memoryStr}];
}

//- (void)beginMonitorFPS
//{
//    [_fps startMonitor];
//}

// record app lifecycle
- (void)markAppStartDurationMistake {
    _ignoreStartDuration = YES;
}

- (void)applicationDidFinishLaunchingWithOptions {
    [self storeEvent:@"didFinishLaunchingWithOptions" remark:@{}];
}

- (void)applicationWillResignActive {

    [self storeEvent:@"willResignActive" remark:@{}];
}

- (void)applicationDidEnterBackground {
    [self storeEvent:@"didEnterBackground" remark:@{}];
    [self stopUpload];
}

- (void)applicationWillEnterForeground {
    [self storeEvent:@"willEnterForeground" remark:@{}];
    [self restartUpload];
}

- (void)applicationDidBecomeActive {
    [self storeEvent:@"didBecomeActive" remark:@{}];
}

- (void)applicationDidReceiveMemoryWarning {
    [self storeEvent:@"didReceiveMemoryWarning" remark:@{}];
    [self collectSystemInfo];
}

- (void)applicationWillTerminate {
    [self storeEvent:@"willTerminate" remark:@{}];
}

- (void)applicationOpenURL:(NSURL *)url {
    [self storeEvent:@"openURL" remark:@{@"url" : url.absoluteString}];
}

- (void)homeVCViewDidAppear {
    if (!_didLaunched) {
        _didLaunched = YES;
        if (_ignoreStartDuration) {
            return;
        }
        NSTimeInterval processCreateTime = [UCARProcessInfo processStartTime];
        CFTimeInterval homeViewDidRenderedTime = [NSDate date].timeIntervalSince1970 * 1000;
        CFTimeInterval duration = homeViewDidRenderedTime - processCreateTime;
        int durationMS = floor(duration);
        NSDictionary *remark = @{@"duration" : @(durationMS), @"endTime": @(CACurrentMediaTime()).stringValue};
        [[UCARMonitorStore sharedStore] storeEvent:@"startDuration" remark:remark];
    }
}

- (void)restartUpload {
    if (_version == UCARMonitorStoreVersionNew) {
        [[UCARMonitorNewStore sharedStore] restartUpload];
    } else {
        [[UCARMonitorOldStore sharedStore] restartUpload];
    }
}

- (void)stopUpload {
    if (_version == UCARMonitorStoreVersionNew) {
        [[UCARMonitorNewStore sharedStore] stopUpload];
    } else {
        [[UCARMonitorOldStore sharedStore] stopUpload];
    }
}

- (void)storeDevice:(nonnull NSDictionary *)remark {
    if (_version == UCARMonitorStoreVersionNew) {
        [[UCARMonitorNewStore sharedStore] storeDevice:remark];
    } else {
        [[UCARMonitorOldStore sharedStore] storeDevice:remark];
    }
}

- (void)storeEvent:(nonnull NSString *)code remark:(nonnull NSDictionary *)remark {
    if (_version == UCARMonitorStoreVersionNew) {
        [[UCARMonitorNewStore sharedStore] storeEvent:code remark:remark];
    } else {
        [[UCARMonitorOldStore sharedStore] storeEvent:code remark:remark];
    }
    
    if ([self.delegate respondsToSelector:@selector(didStoreEvent:remark:)]) {
        [self.delegate didStoreEvent:code remark:remark];
    }
}

- (void)storeRoute:(nonnull NSString *)pageName
            action:(UCARMonitorStoreRouteAction)action
            remark:(nonnull NSDictionary *)remark {
    if (_version == UCARMonitorStoreVersionNew) {
        [[UCARMonitorNewStore sharedStore] storeRoute:pageName action:action remark:remark];
    } else {
        [[UCARMonitorOldStore sharedStore] storeRoute:pageName action:action remark:remark];
    }
    
    if ([self.delegate respondsToSelector:@selector(didStoreRoute:action:remark:)]) {
        [self.delegate didStoreRoute:pageName action:action remark:remark];
    }
}

- (void)storeException:(nonnull NSString *)code
                 stack:(nonnull NSDictionary *)stack
                remark:(nonnull NSDictionary *)remark {
    if (_version == UCARMonitorStoreVersionNew) {
        [[UCARMonitorNewStore sharedStore] storeException:code stack:stack remark:remark];
    } else {
        [[UCARMonitorOldStore sharedStore] storeException:code stack:stack remark:remark];
    }
}

- (void)storePerformance:(nonnull NSString *)code remark:(nonnull NSDictionary *)remark {
    if (_version == UCARMonitorStoreVersionNew) {
        [[UCARMonitorNewStore sharedStore] storePerformance:code remark:remark];
    } else {
        [[UCARMonitorOldStore sharedStore] storeEvent:code remark:remark];
    }
}

- (void)storeDNS:(nonnull NSString *)domain
              IP:(nonnull NSString *)IP
        hijackIP:(nonnull NSString *)hijackIP
          remark:(nonnull NSDictionary *)remark {
    if (_version == UCARMonitorStoreVersionNew) {
        [[UCARMonitorNewStore sharedStore] storeDNS:domain IP:IP hijackIP:hijackIP remark:remark];
    } else {
        NSDictionary *remarkDict = @{@"domain" : domain, @"ip" : IP, @"hijackIP" : hijackIP, @"remark" : remark};
        [[UCARMonitorOldStore sharedStore] storeEvent:@"domain" remark:remarkDict];
    }
}

// 反作弊数据验证
- (void)storeDriverCheating:(nonnull UCARMonitorOldStoreDriverCheating *)driverCheating {
    [[UCARMonitorOldStore sharedStore] storeDriverCheating:driverCheating];
}

// https://developer.apple.com/library/archive/qa/qa1480/_index.html
+ (NSString *)getTimeString
// Returns a user-visible date time string that corresponds to the
// specified RFC 3339 date time string. Note that this does not handle
// all possible RFC 3339 date time strings, just one of the most common
// styles.
{
    static NSDateFormatter *sRFC3339DateFormatter;

    // If the date formatters aren't already set up, do that now and cache them
    // for subsequence reuse.

    if (sRFC3339DateFormatter == nil) {
        NSLocale *enUSPOSIXLocale;

        sRFC3339DateFormatter = [[NSDateFormatter alloc] init];

        enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];

        [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
        [sRFC3339DateFormatter setDateFormat:UCARMonitorStoreDateFormat];
        [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GTM+8"]];
    }

    NSString *timeString = [sRFC3339DateFormatter stringFromDate:[NSDate date]];

    return timeString;
}

+ (NSString *)stringFromJSONObject:(NSDictionary *)parameters {
    if (parameters) {
        if (![NSJSONSerialization isValidJSONObject:parameters]) {
            // 无效 JSON 对象
            return @"{\"key\":\"data error.\"}";
        }
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
        if (data) {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } else {
            return UCARMonitorStoreDefaultRemark;
        }
    } else {
        return UCARMonitorStoreDefaultRemark;
    }
}

//=======================紧急统计事件==========================

- (void)sendEvent:(nonnull NSString *)code remark:(nonnull NSDictionary *)remark {
    if (_version == UCARMonitorStoreVersionNew) {
        [[UCARMonitorNewStore sharedStore] sendEvent:code remark:remark];
    } else {
        [[UCARMonitorOldStore sharedStore] sendEvent:code remark:remark];
    }
}

@end
