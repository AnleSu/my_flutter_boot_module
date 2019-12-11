//
//  UCARMonitorNewStoreORM.m
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import "UCARMonitorNewStoreORM.h"
#import "UCARMonitorStore.h"
#import <AFNetworking/AFNetworking.h>
#import <UCARUtility/UCARUtility.h>
#import <UCARDeviceToken/UCARDeviceToken.h>
#import <objc/runtime.h>

@implementation UCARMonitorNewStoreCommonInfo

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _app_version = UCARMonitorStoreDefaultValue;
        _user_id = UCARMonitorStoreDefaultValue;
        _app_name = UCARMonitorStoreDefaultValue;
        _session_id = UCARMonitorStoreDefaultValue;
        _token_id = UCARMonitorStoreDefaultValue;

        _channel = @"App_Store";
        _longitude = UCARMonitorStoreDefaultValue;
        _latitude = UCARMonitorStoreDefaultValue;
        _device_imei = [UCARDeviceToken deviceUUID];
        _platform = @"iOS";
        _mobile = UCARMonitorStoreDefaultValue;
        _event_id = [UCAREventIDGenerator generateEventID];
        //当前页面，此值不用
        _current_info = UCARMonitorStoreDefaultValue;
        _time = [UCARMonitorStore getTimeString];
    }
    return self;
}

- (NSArray *)propertyKeys {
    NSMutableArray *properties = [NSMutableArray array];
    Class cls = self.class;
    while (cls) {
        if ([NSStringFromClass(cls) isEqualToString:@"NSObject"]) {
            break;
        }
        unsigned int propertyCount;
        objc_property_t *propertyList = class_copyPropertyList(cls, &propertyCount);
        for (unsigned int i = 0; i < propertyCount; i++) {
            // get property name
            objc_property_t property = propertyList[i];
            const char *propertyName = property_getName(property);
            NSString *propertyStr = [[NSString alloc] initWithUTF8String:propertyName];
            [properties addObject:propertyStr];
        }
        free(propertyList);
        cls = [cls superclass];
    }
    return properties;
}

- (NSDictionary *)convertSelfToDict {
    return [self dictionaryWithValuesForKeys:[self propertyKeys]];
}

#pragma coding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }

    _app_version = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(app_version))];
    _user_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user_id))];
    _app_name = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(app_name))];
    _session_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(session_id))];
    _token_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(token_id))];
    _channel = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(channel))];
    _longitude = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(longitude))];
    _latitude = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(latitude))];
    _device_imei = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_imei))];
    _platform = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(platform))];
    _mobile = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mobile))];
    _event_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(event_id))];
    _current_info = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(current_info))];
    _time = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(time))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_app_version forKey:NSStringFromSelector(@selector(app_version))];
    [aCoder encodeObject:_user_id forKey:NSStringFromSelector(@selector(user_id))];
    [aCoder encodeObject:_app_name forKey:NSStringFromSelector(@selector(app_name))];
    [aCoder encodeObject:_session_id forKey:NSStringFromSelector(@selector(session_id))];
    [aCoder encodeObject:_token_id forKey:NSStringFromSelector(@selector(token_id))];
    [aCoder encodeObject:_channel forKey:NSStringFromSelector(@selector(channel))];
    [aCoder encodeObject:_longitude forKey:NSStringFromSelector(@selector(longitude))];
    [aCoder encodeObject:_latitude forKey:NSStringFromSelector(@selector(latitude))];
    [aCoder encodeObject:_device_imei forKey:NSStringFromSelector(@selector(device_imei))];
    [aCoder encodeObject:_platform forKey:NSStringFromSelector(@selector(platform))];
    [aCoder encodeObject:_mobile forKey:NSStringFromSelector(@selector(mobile))];
    [aCoder encodeObject:_event_id forKey:NSStringFromSelector(@selector(event_id))];
    [aCoder encodeObject:_current_info forKey:NSStringFromSelector(@selector(current_info))];
    [aCoder encodeObject:_time forKey:NSStringFromSelector(@selector(time))];
}

@end

@implementation UCARMonitorNewStoreDevice

- (instancetype)init {
    self = [super init];
    if (self) {
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGFloat width = rect.size.width;
        CGFloat height = rect.size.height;
        CGFloat scale_screen = [UIScreen mainScreen].scale;
        NSString *screenResolution =
            [NSString stringWithFormat:@"%.0f*%.0f", width * scale_screen, height * scale_screen];

        NSString *deviceStatus = [UCARSystemInfo isJailbreak] ? @"JailBreak" : @"NORMAL";

        //注意，统计结果偏向WiFi
        NSString *netType = @"WIFI";
        switch ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus) {
            case AFNetworkReachabilityStatusNotReachable:
                netType = @"无网络";
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                netType = [UCARSystemInfo cellularType];
            default:
                break;
        }

        _type = @"device";
        _device_brand = @"apple";
        _device_model = [UCARSystemInfo getCurrentDeviceModel];
        _system_status = deviceStatus;
        _mobile_operator = [UCARSystemInfo carrierName];
        _net_type = netType;
        _device_remark = UCARMonitorStoreDefaultRemark;
        _device_screen_resolution = screenResolution;
        _device_system_version = [UIDevice currentDevice].systemVersion;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }

    _type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(type))];
    _device_brand = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_brand))];
    _device_model = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_model))];
    _system_status = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(system_status))];
    _mobile_operator = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mobile_operator))];
    _net_type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(net_type))];
    _device_remark = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_remark))];
    _device_screen_resolution = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_screen_resolution))];
    _device_system_version = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_system_version))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_device_brand forKey:NSStringFromSelector(@selector(device_brand))];
    [aCoder encodeObject:_device_model forKey:NSStringFromSelector(@selector(device_model))];
    [aCoder encodeObject:_system_status forKey:NSStringFromSelector(@selector(system_status))];
    [aCoder encodeObject:_mobile_operator forKey:NSStringFromSelector(@selector(mobile_operator))];
    [aCoder encodeObject:_net_type forKey:NSStringFromSelector(@selector(net_type))];
    [aCoder encodeObject:_device_remark forKey:NSStringFromSelector(@selector(device_remark))];
    [aCoder encodeObject:_device_screen_resolution forKey:NSStringFromSelector(@selector(device_screen_resolution))];
    [aCoder encodeObject:_device_system_version forKey:NSStringFromSelector(@selector(device_system_version))];
}

@end

@implementation UCARMonitorNewStoreEvent

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"event";
        _event_code = UCARMonitorStoreDefaultValue;
        _event_name = UCARMonitorStoreDefaultValue;
        _event_remark = UCARMonitorStoreDefaultRemark;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }

    _type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(type))];
    _event_code = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(event_code))];
    _event_name = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(event_name))];
    _event_remark = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(event_remark))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_event_code forKey:NSStringFromSelector(@selector(event_code))];
    [aCoder encodeObject:_event_name forKey:NSStringFromSelector(@selector(event_name))];
    [aCoder encodeObject:_event_remark forKey:NSStringFromSelector(@selector(event_remark))];
}

@end

@implementation UCARMonitorNewStoreRoute

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"route";
        _route_activity_code = UCARMonitorStoreDefaultValue;
        _route_start_time = UCARMonitorStoreDefaultValue;
        _route_duration = UCARMonitorStoreDefaultValue;
        _route_end_time = UCARMonitorStoreDefaultValue;
        _action = UCARMonitorStoreDefaultValue;
        _route_remark = UCARMonitorStoreDefaultRemark;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }

    _type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(type))];
    _route_activity_code = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(route_activity_code))];
    _route_start_time = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(route_start_time))];
    _route_duration = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(route_duration))];
    _route_end_time = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(route_end_time))];
    _action = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(action))];
    _route_remark = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(route_remark))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_route_activity_code forKey:NSStringFromSelector(@selector(route_activity_code))];
    [aCoder encodeObject:_route_start_time forKey:NSStringFromSelector(@selector(route_start_time))];
    [aCoder encodeObject:_route_duration forKey:NSStringFromSelector(@selector(route_duration))];
    [aCoder encodeObject:_route_end_time forKey:NSStringFromSelector(@selector(route_end_time))];
    [aCoder encodeObject:_action forKey:NSStringFromSelector(@selector(action))];
    [aCoder encodeObject:_route_remark forKey:NSStringFromSelector(@selector(route_remark))];
}

@end

@implementation UCARMonitorNewStoreException

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"exception";
        _exception_code = UCARMonitorStoreDefaultValue;
        _exception_remark = UCARMonitorStoreDefaultRemark;
        _exception_stack = UCARMonitorStoreDefaultValue;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }

    _type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(type))];
    _exception_code = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(exception_code))];
    _exception_remark = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(exception_remark))];
    _exception_stack = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(exception_stack))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_exception_code forKey:NSStringFromSelector(@selector(exception_code))];
    [aCoder encodeObject:_exception_remark forKey:NSStringFromSelector(@selector(exception_remark))];
    [aCoder encodeObject:_exception_stack forKey:NSStringFromSelector(@selector(exception_stack))];
}

@end

@implementation UCARMonitorNewStorePerformance

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"performance";
        _perf_code = UCARMonitorStoreDefaultValue;
        _perf_remark = UCARMonitorStoreDefaultRemark;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    _type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(type))];
    _perf_code = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(perf_code))];
    _perf_remark = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(perf_remark))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_perf_code forKey:NSStringFromSelector(@selector(perf_code))];
    [aCoder encodeObject:_perf_remark forKey:NSStringFromSelector(@selector(perf_remark))];
}

@end

@implementation UCARMonitorNewStoreDNS

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"dns";
        _device_domain = UCARMonitorStoreDefaultValue;
        _dns_hijack_ip = UCARMonitorStoreDefaultValue;
        _dns_ip = UCARMonitorStoreDefaultValue;
        _dns_remark = UCARMonitorStoreDefaultRemark;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    _type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(type))];
    _device_domain = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_domain))];
    _dns_hijack_ip = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dns_hijack_ip))];
    _dns_ip = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dns_ip))];
    _dns_remark = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dns_remark))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_device_domain forKey:NSStringFromSelector(@selector(device_domain))];
    [aCoder encodeObject:_dns_hijack_ip forKey:NSStringFromSelector(@selector(dns_hijack_ip))];
    [aCoder encodeObject:_dns_ip forKey:NSStringFromSelector(@selector(dns_ip))];
    [aCoder encodeObject:_dns_remark forKey:NSStringFromSelector(@selector(dns_remark))];
}

@end

@implementation UCARMonitorNewStoreLog

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"log";
        _log_tag = UCARMonitorStoreDefaultValue;
        _log_content = UCARMonitorStoreDefaultRemark;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    _type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(type))];
    _log_tag = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(log_tag))];
    _log_content = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(log_content))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_log_tag forKey:NSStringFromSelector(@selector(log_tag))];
    [aCoder encodeObject:_log_content forKey:NSStringFromSelector(@selector(log_content))];
}

@end
