//
//  UCARMonitorOldStoreORM.m
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import "UCARMonitorOldStoreORM.h"
#import "UCARMonitorStore.h"
#import <AFNetworking/AFNetworking.h>
#import <UCARUtility/UCARUtility.h>
#import <UCARDeviceToken/UCARDeviceToken.h>
#import <objc/runtime.h>

@implementation UCARMonitorOldStoreCommonInfo

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _device_imei = [UCARDeviceToken deviceUUID];
        _device_openid = _device_imei;
        _device_type = @"iOS";
        _device_channel = @"App_Store";
        _user_type = UCARMonitorStoreDefaultValue;
        _event_id = [UCAREventIDGenerator generateEventID];
        //当前页面，此值不用
        _current_info = @"";

        _app_version = UCARMonitorStoreDefaultValue;
        _client_id = UCARMonitorStoreDefaultValue;
        _user_id = UCARMonitorStoreDefaultValue;
        _device_city_id = UCARMonitorStoreDefaultValue;
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

    _device_imei = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_imei))];
    _device_openid = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_openid))];
    _device_type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_type))];
    _device_channel = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_channel))];
    _user_type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user_type))];
    _event_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(event_id))];
    _current_info = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(current_info))];

    _app_version = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(app_version))];
    _client_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(client_id))];
    _user_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user_id))];
    _device_city_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_city_id))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_device_imei forKey:NSStringFromSelector(@selector(device_imei))];
    [aCoder encodeObject:_device_openid forKey:NSStringFromSelector(@selector(device_openid))];
    [aCoder encodeObject:_device_type forKey:NSStringFromSelector(@selector(device_type))];
    [aCoder encodeObject:_device_channel forKey:NSStringFromSelector(@selector(device_channel))];
    [aCoder encodeObject:_user_type forKey:NSStringFromSelector(@selector(user_type))];
    [aCoder encodeObject:_event_id forKey:NSStringFromSelector(@selector(event_id))];
    [aCoder encodeObject:_current_info forKey:NSStringFromSelector(@selector(current_info))];

    [aCoder encodeObject:_app_version forKey:NSStringFromSelector(@selector(app_version))];
    [aCoder encodeObject:_client_id forKey:NSStringFromSelector(@selector(client_id))];
    [aCoder encodeObject:_user_id forKey:NSStringFromSelector(@selector(user_id))];
    [aCoder encodeObject:_device_city_id forKey:NSStringFromSelector(@selector(device_city_id))];
}

@end

@implementation UCARMonitorOldStoreDevice

- (instancetype)init {
    self = [super init];
    if (self) {
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGFloat width = rect.size.width;
        CGFloat height = rect.size.height;
        CGFloat scale_screen = [UIScreen mainScreen].scale;
        NSString *screenResolution =
            [NSString stringWithFormat:@"(w = %.2f, h = %.2f)", width * scale_screen, height * scale_screen];

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
        _device_sys_version = [UIDevice currentDevice].systemVersion;
        _device_net_type = netType;
        _device_mobile_operator = [UCARSystemInfo carrierName];
        _device_device_status = deviceStatus;
        _device_screen_resolution = screenResolution;
        _device_time = [UCARMonitorStore getTimeString];
        _device_remark = UCARMonitorStoreDefaultRemark;
        _device_app_version = UCARMonitorStoreDefaultValue;
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
    _device_sys_version = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_sys_version))];
    _device_net_type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_net_type))];
    _device_mobile_operator = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_mobile_operator))];
    _device_device_status = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_device_status))];
    _device_screen_resolution = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_screen_resolution))];
    _device_time = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_time))];
    _device_remark = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_remark))];
    _device_app_version = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_app_version))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_device_brand forKey:NSStringFromSelector(@selector(device_brand))];
    [aCoder encodeObject:_device_model forKey:NSStringFromSelector(@selector(device_model))];
    [aCoder encodeObject:_device_sys_version forKey:NSStringFromSelector(@selector(device_sys_version))];
    [aCoder encodeObject:_device_net_type forKey:NSStringFromSelector(@selector(device_net_type))];
    [aCoder encodeObject:_device_mobile_operator forKey:NSStringFromSelector(@selector(device_mobile_operator))];
    [aCoder encodeObject:_device_device_status forKey:NSStringFromSelector(@selector(device_device_status))];
    [aCoder encodeObject:_device_screen_resolution forKey:NSStringFromSelector(@selector(device_screen_resolution))];

    [aCoder encodeObject:_device_time forKey:NSStringFromSelector(@selector(device_time))];
    [aCoder encodeObject:_device_remark forKey:NSStringFromSelector(@selector(device_remark))];
    [aCoder encodeObject:_device_app_version forKey:NSStringFromSelector(@selector(device_app_version))];
}

@end

@implementation UCARMonitorOldStoreEvent

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"event";
        _event_event_time = [UCARMonitorStore getTimeString];
        _event_order_id = UCARMonitorStoreDefaultValue;
        _event_event_code = UCARMonitorStoreDefaultValue;
        _event_event_remark = UCARMonitorStoreDefaultRemark;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }

    _type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(type))];
    _event_event_time = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(event_event_time))];
    _event_order_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(event_order_id))];
    _event_event_code = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(event_event_code))];
    _event_event_remark = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(event_event_remark))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_event_event_time forKey:NSStringFromSelector(@selector(event_event_time))];
    [aCoder encodeObject:_event_order_id forKey:NSStringFromSelector(@selector(event_order_id))];
    [aCoder encodeObject:_event_event_code forKey:NSStringFromSelector(@selector(event_event_code))];
    [aCoder encodeObject:_event_event_remark forKey:NSStringFromSelector(@selector(event_event_remark))];
}

@end

@implementation UCARMonitorOldStoreRoute

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"route";
        _route_widget_code = @"";
        _route_remark = UCARMonitorStoreDefaultRemark;
        _route_time = [UCARMonitorStore getTimeString];
        _route_activity_code = UCARMonitorStoreDefaultValue;
        _route_event = UCARMonitorStoreDefaultValue;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }

    _type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(type))];
    _route_widget_code = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(route_widget_code))];
    _route_remark = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(route_remark))];
    _route_time = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(route_time))];
    _route_activity_code = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(route_activity_code))];
    _route_event = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(route_event))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_route_widget_code forKey:NSStringFromSelector(@selector(route_widget_code))];
    [aCoder encodeObject:_route_remark forKey:NSStringFromSelector(@selector(route_remark))];
    [aCoder encodeObject:_route_time forKey:NSStringFromSelector(@selector(route_time))];
    [aCoder encodeObject:_route_activity_code forKey:NSStringFromSelector(@selector(route_activity_code))];
    [aCoder encodeObject:_route_event forKey:NSStringFromSelector(@selector(route_event))];
}

@end

@implementation UCARMonitorOldStoreDNS

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"dns";
        _dns_user_type = self.user_type;
        _dns_poi = UCARMonitorStoreDefaultValue;
        _dns_time = [UCARMonitorStore getTimeString];

        _device_domain = UCARMonitorStoreDefaultValue;
        _dns_ip = UCARMonitorStoreDefaultValue;
        _dns_user_id = UCARMonitorStoreDefaultValue;
        _dns_city_id = UCARMonitorStoreDefaultValue;
        _dns_app_version = UCARMonitorStoreDefaultValue;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }

    _type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(type))];
    _dns_user_type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dns_user_type))];
    _dns_poi = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dns_poi))];
    _dns_time = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dns_time))];
    _device_domain = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(device_domain))];
    _dns_ip = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dns_ip))];
    _dns_user_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dns_user_id))];
    _dns_city_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dns_city_id))];
    _dns_app_version = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dns_app_version))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_dns_user_type forKey:NSStringFromSelector(@selector(dns_user_type))];
    [aCoder encodeObject:_dns_poi forKey:NSStringFromSelector(@selector(dns_poi))];
    [aCoder encodeObject:_dns_time forKey:NSStringFromSelector(@selector(dns_time))];
    [aCoder encodeObject:_device_domain forKey:NSStringFromSelector(@selector(device_domain))];
    [aCoder encodeObject:_dns_ip forKey:NSStringFromSelector(@selector(dns_ip))];
    [aCoder encodeObject:_dns_user_id forKey:NSStringFromSelector(@selector(dns_user_id))];
    [aCoder encodeObject:_dns_city_id forKey:NSStringFromSelector(@selector(dns_city_id))];
    [aCoder encodeObject:_dns_app_version forKey:NSStringFromSelector(@selector(dns_app_version))];
}

@end

@implementation UCARMonitorOldStoreException

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"exception";
        _exception_time = [UCARMonitorStore getTimeString];

        _exception_code = UCARMonitorStoreDefaultValue;
        _exception_stack = UCARMonitorStoreDefaultValue;
        _exception_remark = UCARMonitorStoreDefaultRemark;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }

    _type = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(type))];
    _exception_time = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(exception_time))];
    _exception_code = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(exception_code))];
    _exception_stack = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(exception_stack))];
    _exception_remark = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(exception_remark))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_exception_time forKey:NSStringFromSelector(@selector(exception_time))];
    [aCoder encodeObject:_exception_code forKey:NSStringFromSelector(@selector(exception_code))];
    [aCoder encodeObject:_exception_stack forKey:NSStringFromSelector(@selector(exception_stack))];
    [aCoder encodeObject:_exception_remark forKey:NSStringFromSelector(@selector(exception_remark))];
}

@end

@implementation UCARMonitorOldStoreLog

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"log";
        _log_time = [UCARMonitorStore getTimeString];

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
    _log_time = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(log_time))];
    _log_tag = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(log_tag))];
    _log_content = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(log_content))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:_log_time forKey:NSStringFromSelector(@selector(log_time))];
    [aCoder encodeObject:_log_tag forKey:NSStringFromSelector(@selector(log_tag))];
    [aCoder encodeObject:_log_content forKey:NSStringFromSelector(@selector(log_content))];
}

@end

@implementation UCARMonitorOldStoreDriverCheating

// init
- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"driverCheating";
        // `UCARMonitorAppNamePCARDriver`
        _app_name = @"0";
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (!self) {
        return nil;
    }
    
    unsigned int propertyCount;
    objc_property_t *propertyList = class_copyPropertyList(self.class, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
        // get property name
        objc_property_t property = propertyList[i];
        const char *propertyName = property_getName(property);
        NSString *propertyStr = [[NSString alloc] initWithUTF8String:propertyName];
        
        id value = [aDecoder decodeObjectForKey:propertyStr];
        [self setValue:value forKey:propertyStr];
    }
    free(propertyList);
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    unsigned int propertyCount;
    objc_property_t *propertyList = class_copyPropertyList(self.class, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
        // get property name
        objc_property_t property = propertyList[i];
        const char *propertyName = property_getName(property);
        NSString *propertyStr = [[NSString alloc] initWithUTF8String:propertyName];
        
        id value = [self valueForKey:propertyStr];
        [aCoder encodeObject:value forKey:propertyStr];
    }
}

@end
