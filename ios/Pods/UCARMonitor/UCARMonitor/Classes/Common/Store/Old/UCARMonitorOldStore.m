//
//  UCARMonitorOldStore.m
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import "UCARMonitorOldStore.h"
#import "UCARMonitorStore.h"
#import <FMDB/FMDB.h>
#import <UCARLogger/UCARLogger.h>

NSString *const UCARMonitorOldStoreCreateTable =
    @"create table if not exists monitor (id integer primary key autoincrement, userType text, appVersion text, "
    @"sessionID text, userID text, cityID text, data blob)";
NSString *const UCARMonitorOldStoreTableInsert =
    @"insert into monitor (userType, appVersion, sessionID, userID, cityID, data) values (?, ?, ?, ?, ?, ?)";
NSString *const UCARMonitorOldStoreTableUpdateUserType = @"update monitor set userType = ? where userType = ?";
NSString *const UCARMonitorOldStoreTableUpdateAppVersion = @"update monitor set appVersion = ? where appVersion = ?";
NSString *const UCARMonitorOldStoreTableUpdateSessionID = @"update monitor set sessionID = ? where sessionID = ?";
NSString *const UCARMonitorOldStoreTableUpdateUserID = @"update monitor set userID = ? where userID = ?";
NSString *const UCARMonitorOldStoreTableUpdateCityID = @"update monitor set cityID = ? where cityID = ?";
NSString *const UCARMonitorOldStoreTableQuery = @"select * from monitor where userID != ? order by id asc limit 100";
NSString *const UCARMonitorOldStoreTableDelete = @"delete from monitor where id >= ? and id <= ?";

static dispatch_queue_t ucar_monitor_old_store_queue() {
    static dispatch_queue_t ucar_monitor_old_store_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ucar_monitor_old_store_queue = dispatch_queue_create("com.szzc.ucar.monitor.store", DISPATCH_QUEUE_SERIAL);
    });

    return ucar_monitor_old_store_queue;
}

@interface UCARMonitorOldStore ()

@property (nonatomic) FMDatabaseQueue *dbQueue;

@end

@implementation UCARMonitorOldStore

+ (instancetype)sharedStore {
    static UCARMonitorOldStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[UCARMonitorOldStore alloc] init];
    });
    return store;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _userType = UCARMonitorStoreDefaultValue;
        _appVersion = UCARMonitorStoreDefaultValue;
        _sessionID = UCARMonitorStoreDefaultValue;
        _userID = UCARMonitorStoreDefaultValue;
        _cityID = UCARMonitorStoreDefaultValue;

        NSString *homePath = NSHomeDirectory();
        NSString *dbPath = [homePath stringByAppendingPathComponent:@"Documents/ucarmonitorold.db"];
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:dbPath];
        [self checkTable];

        _uploader = [[UCARMonitorUploader alloc] init];
        _uploader.sessionID = @"";
        _uploader.dataSource = self;
    }
    return self;
}

#pragma mark FMDB
//将所有db操作全部放到异步线程执行

- (void)checkTable {
    dispatch_async(ucar_monitor_old_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorOldStoreCreateTable];
        }];
    });
}

- (void)setUserType:(NSString *)userType {
    _userType = userType;
    dispatch_async(ucar_monitor_old_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorOldStoreTableUpdateUserType, userType, UCARMonitorStoreDefaultValue];
        }];
    });
}

- (void)setAppVersion:(NSString *)appVersion {
    _appVersion = appVersion;
    dispatch_async(ucar_monitor_old_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorOldStoreTableUpdateAppVersion, appVersion, UCARMonitorStoreDefaultValue];
        }];
    });
}

- (void)setSessionID:(NSString *)sessionID {
    _sessionID = sessionID;
    _uploader.sessionID = sessionID;
    dispatch_async(ucar_monitor_old_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorOldStoreTableUpdateSessionID, sessionID, UCARMonitorStoreDefaultValue];
        }];
    });
}

- (void)setUserID:(NSString *)userID {
    _userID = userID;
    dispatch_async(ucar_monitor_old_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorOldStoreTableUpdateUserID, userID, UCARMonitorStoreDefaultValue];
        }];
    });
}

- (void)setCityID:(NSString *)cityID {
    _cityID = cityID;
    dispatch_async(ucar_monitor_old_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorOldStoreTableUpdateCityID, cityID, UCARMonitorStoreDefaultValue];
        }];
    });
}

- (void)storeData:(UCARMonitorOldStoreCommonInfo *)data {
    dispatch_async(ucar_monitor_old_store_queue(), ^{
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:data];
        
        if (!archivedData) {
            // 附加描述
            NSString *otherDesc = [NSString stringWithFormat:@"%@_%@_%@_%@_%@", self.userType, self.appVersion, self.sessionID, self.userID, self.cityID];
            // 日志上报
            [self dataErrorWithClazz:data.class method:@"storeData:" otherDesc:otherDesc];
            return;
        }
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorOldStoreTableInsert, self.userType, self.appVersion, self.sessionID,
                              self.userID, self.cityID, archivedData];
        }];
    });
}

- (void)fetchData:(UCARMonitorStoreFetchData)dataBlock {
    dispatch_async(ucar_monitor_old_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            // auto-generated row IDs are always greater than zero
            long minID = -1;
            long maxID = -1;
            FMResultSet *rs = [db executeQuery:UCARMonitorOldStoreTableQuery, UCARMonitorStoreDefaultValue];
            NSMutableArray *list = [NSMutableArray array];
            while ([rs next]) {
                long currentID = [rs longForColumn:@"id"];
                if (minID < 0) {
                    minID = currentID;
                }
                if (maxID < 0) {
                    maxID = currentID;
                }
                if (currentID > maxID) {
                    maxID = currentID;
                }
                if (currentID < minID) {
                    minID = currentID;
                }
                NSString *userType = [rs stringForColumn:@"userType"];
                NSString *appVersion = [rs stringForColumn:@"appVersion"];
                NSString *sessionID = [rs stringForColumn:@"sessionID"];
                NSString *userID = [rs stringForColumn:@"userID"];
                NSString *cityID = [rs stringForColumn:@"cityID"];
                NSData *data = [rs dataForColumn:@"data"];
                NSDictionary *dict = [self convertData:data
                                              userType:userType
                                            appVersion:appVersion
                                             sessionID:sessionID
                                                userID:userID
                                                cityID:cityID];
                UCARLoggerVerbose(@"UCARMonitorStore fetchData %@", dict);
                
                if (dict) {
                    [list addObject:dict];
                } else {
                    // 附加描述
                    NSString *otherDesc = [NSString stringWithFormat:@"%@_%@_%@_%@_%@", userType, appVersion, sessionID, userID, cityID];
                    // 出错 日志上报 (通过 data.class 可以判断 data 是否为 nil)
                    [self dataErrorWithClazz:data.class method:@"fetchData:" otherDesc:otherDesc];
                }
            }
            dataBlock(list);
            //发送后即删除
            [db executeUpdate:UCARMonitorOldStoreTableDelete, @(minID), @(maxID)];
        }];
    });
}

- (NSDictionary *)convertData:(NSData *)data
                     userType:(NSString *)userType
                   appVersion:(NSString *)appVersion
                    sessionID:(NSString *)sessionID
                       userID:(NSString *)userID
                       cityID:(NSString *)cityID {
    UCARMonitorOldStoreCommonInfo *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    info.user_type = userType;
    info.app_version = appVersion;
    info.client_id = sessionID;
    info.user_id = userID;
    info.device_city_id = cityID;

    if ([info isKindOfClass:UCARMonitorOldStoreDevice.class]) {
        UCARMonitorOldStoreDevice *device = (UCARMonitorOldStoreDevice *)info;
        device.device_app_version = appVersion;
    }

    if ([info isKindOfClass:UCARMonitorOldStoreDNS.class]) {
        UCARMonitorOldStoreDNS *dns = (UCARMonitorOldStoreDNS *)info;
        dns.dns_user_id = userID;
        dns.dns_city_id = cityID;
        dns.dns_app_version = appVersion;
    }
    
    NSDictionary *infoDict = [info convertSelfToDict];
    
    if ([info isKindOfClass:UCARMonitorOldStoreDriverCheating.class]) {
        NSMutableDictionary *infoDictM = infoDict.mutableCopy;
        for (NSString *key in infoDict) {
            id value = infoDict[key];
            if (!value || [value isEqual:[NSNull null]]) {
                // 置空
                [infoDictM setValue:UCARMonitorStoreDefaultValue forKey:key];
            } else if ([value isKindOfClass:NSNumber.class]) {
                // 数字转字符串
                [infoDictM setValue:[NSString stringWithFormat:@"%@", value] forKey:key];
            } else if ([value isKindOfClass:NSDictionary.class]) {
                // 字典转 JSON
                NSString* JSONString =  [UCARMonitorStore stringFromJSONObject:value];
                [infoDictM setValue:JSONString forKey:key];
            }
        }
        
        infoDict = infoDictM.copy;
    }
    
    return infoDict;
}

#pragma mark store
- (void)storeDevice:(nonnull NSDictionary *)remark {
    UCARMonitorOldStoreDevice *device = [[UCARMonitorOldStoreDevice alloc] init];
    device.device_remark = [UCARMonitorStore stringFromJSONObject:remark];
    [self storeData:device];
}

- (void)storeEvent:(NSString *)code remark:(NSDictionary *)remark {
    UCARMonitorOldStoreEvent *event = [[UCARMonitorOldStoreEvent alloc] init];
    event.event_event_code = code;
    event.event_event_remark = [UCARMonitorStore stringFromJSONObject:remark];
    [self storeData:event];
}

- (void)storeRoute:(NSString *)pageName
            action:(UCARMonitorStoreRouteAction)action
            remark:(nonnull NSDictionary *)remark {
    UCARMonitorOldStoreRoute *route = [[UCARMonitorOldStoreRoute alloc] init];
    route.route_activity_code = pageName;
    route.route_remark = [UCARMonitorStore stringFromJSONObject:remark];
    switch (action) {
        case UCARMonitorStoreRouteActionInto:
            route.route_event = @"into";
            break;
        case UCARMonitorStoreRouteActionLeave:
            route.route_event = @"leave";
        default:
            break;
    }
    [self storeData:route];
}

- (void)storeDNS:(NSString *)domain IP:(NSString *)IP {
    UCARMonitorOldStoreDNS *dns = [[UCARMonitorOldStoreDNS alloc] init];
    dns.device_domain = domain;
    dns.dns_ip = IP;
    [self storeData:dns];
}

- (void)storeException:(NSString *)code stack:(NSDictionary *)stack remark:(NSDictionary *)remark {
    UCARMonitorOldStoreException *exception = [[UCARMonitorOldStoreException alloc] init];
    exception.exception_code = code;
    exception.exception_stack = [UCARMonitorStore stringFromJSONObject:stack];
    exception.exception_remark = [UCARMonitorStore stringFromJSONObject:remark];
    [self storeData:exception];
}

- (void)storeLog:(NSString *)tag content:(NSString *)content {
    UCARMonitorOldStoreLog *log = [[UCARMonitorOldStoreLog alloc] init];
    log.log_tag = tag;
    log.log_content = content;
    [self storeData:log];
}

// 反作弊数据验证
- (void)storeDriverCheating:(nonnull UCARMonitorOldStoreDriverCheating *)driverCheating {
    [self storeData:driverCheating];
}

#pragma mark upload
- (void)restartUpload {
    [_uploader connectHost];
}


- (void)stopUpload {
    [_uploader stopUpload];
}

//=======================紧急统计事件==========================

- (void)sendEvent:(nonnull NSString *)code remark:(nonnull NSDictionary *)remark {
    if ([self.userID isEqualToString:UCARMonitorStoreDefaultValue] || (!self.uploader.socketConnected)) {
        [self storeEvent:code remark:remark];
    } else {
        UCARMonitorOldStoreEvent *event = [[UCARMonitorOldStoreEvent alloc] init];
        event.event_event_code = code;
        event.event_event_remark = [UCARMonitorStore stringFromJSONObject:remark];

        event.user_type = self.userType;
        event.app_version = self.appVersion;
        event.client_id = self.sessionID;
        event.user_id = self.userID;
        event.device_city_id = self.cityID;

        NSDictionary *dict = [event convertSelfToDict];
        NSArray *list = @[ dict ];
        [self.uploader sendData:list];
    }
}

// archivedData 错误解析日志上报
- (void)dataErrorWithClazz:(Class)clazz method:(NSString*)method otherDesc:(NSString*)otherDesc {
    NSDictionary *remark = @{
                             @"clazz":NSStringFromClass(clazz)?:@"",
                             @"method":method?:@"",
                             @"otherDesc":otherDesc?:@"",
                             @"self":NSStringFromClass(self.class)
                             };
    [self storeEvent:@"MonitorDataError" remark:remark];
}

@end
