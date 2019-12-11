//
//  UCARMonitorNewStore.m
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import "UCARMonitorNewStore.h"
#import "UCARMonitorStore.h"
#import <FMDB/FMDB.h>
#import <UCARLogger/UCARLogger.h>

NSString *const UCARMonitorNewStoreCreateTable =
    @"create table if not exists monitor (id integer primary key autoincrement, appVersion text, userID text, appName "
    @"text, sessionID text, longitude text, latitude text, mobile text, data blob);";
NSString *const UCARMonitorNewStoreTableInsert = @"insert into monitor (appVersion, userID, appName, sessionID, "
                                                 @"longitude, latitude, mobile, data) values (?, ?, ?, ?, ?, ?, ?, ?)";
NSString *const UCARMonitorNewStoreTableUpdateAppVersion = @"update monitor set appVersion = ? where appVersion = ?";
NSString *const UCARMonitorNewStoreTableUpdateUserID = @"update monitor set userID = ? where userID = ?";
NSString *const UCARMonitorNewStoreTableUpdateAppName = @"update monitor set appName = ? where appName = ?";
NSString *const UCARMonitorNewStoreTableUpdateSessionID = @"update monitor set sessionID = ? where sessionID = ?";
NSString *const UCARMonitorNewStoreTableUpdateLongitude = @"update monitor set longitude = ? where longitude = ?";
NSString *const UCARMonitorNewStoreTableUpdateLatitude = @"update monitor set latitude = ? where latitude = ?";
NSString *const UCARMonitorNewStoreTableUpdateMobile = @"update monitor set mobile = ? where mobile = ?";

NSString *const UCARMonitorNewStoreTableQuery = @"select * from monitor where userID != ? order by id asc limit 100";
NSString *const UCARMonitorNewStoreTableDelete = @"delete from monitor where id >= ? and id <= ?";

static dispatch_queue_t ucar_monitor_new_store_queue() {
    static dispatch_queue_t ucar_monitor_new_store_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ucar_monitor_new_store_queue = dispatch_queue_create("com.szzc.ucar.monitor.store", DISPATCH_QUEUE_SERIAL);
    });

    return ucar_monitor_new_store_queue;
}

@interface UCARMonitorNewStore ()

@property (nonatomic) FMDatabaseQueue *dbQueue;

@property (nonatomic) NSString *appNameStr;

@end

@implementation UCARMonitorNewStore

+ (instancetype)sharedStore {
    static UCARMonitorNewStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[UCARMonitorNewStore alloc] init];
    });
    return store;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _appVersion = UCARMonitorStoreDefaultValue;
        _userID = UCARMonitorStoreDefaultValue;
        _appName = UCARMonitorAppNameYCC;
        _sessionID = UCARMonitorStoreDefaultValue;
        _longitude = UCARMonitorStoreDefaultValue;
        _latitude = UCARMonitorStoreDefaultValue;
        _mobile = UCARMonitorStoreDefaultValue;

        _appNameStr = UCARMonitorStoreDefaultValue;

        NSString *homePath = NSHomeDirectory();
        NSString *dbPath = [homePath stringByAppendingPathComponent:@"Documents/ucarmonitornew.db"];

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
    dispatch_async(ucar_monitor_new_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorNewStoreCreateTable];
        }];
    });
}

- (void)setAppVersion:(NSString *)appVersion {
    _appVersion = appVersion;
    dispatch_async(ucar_monitor_new_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorNewStoreTableUpdateAppVersion, appVersion, UCARMonitorStoreDefaultValue];
        }];
    });
}

- (void)setUserID:(NSString *)userID {
    _userID = userID;
    dispatch_async(ucar_monitor_new_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorNewStoreTableUpdateUserID, userID, UCARMonitorStoreDefaultValue];
        }];
    });
}

- (void)setAppName:(UCARMonitorAppName)appName {
    _appName = appName;
    self.appNameStr = @(appName).stringValue;
}

- (void)setSessionID:(NSString *)sessionID {
    _sessionID = sessionID;
    _uploader.sessionID = sessionID;
    dispatch_async(ucar_monitor_new_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorNewStoreTableUpdateSessionID, sessionID, UCARMonitorStoreDefaultValue];
        }];
    });
}

- (void)setLongitude:(NSString *)longitude {
    _longitude = longitude;
    dispatch_async(ucar_monitor_new_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorNewStoreTableUpdateLongitude, longitude, UCARMonitorStoreDefaultValue];
        }];
    });
}

- (void)setLatitude:(NSString *)latitude {
    _latitude = latitude;
    dispatch_async(ucar_monitor_new_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorNewStoreTableUpdateLatitude, latitude, UCARMonitorStoreDefaultValue];
        }];
    });
}

- (void)setMobile:(NSString *)mobile {
    _mobile = mobile;
    dispatch_async(ucar_monitor_new_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorNewStoreTableUpdateMobile, mobile, UCARMonitorStoreDefaultValue];
        }];
    });
}

- (void)setAppNameStr:(NSString *)appNameStr {
    _appNameStr = appNameStr;
    dispatch_async(ucar_monitor_new_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorNewStoreTableUpdateAppName, appNameStr, UCARMonitorStoreDefaultValue];
        }];
    });
}

- (void)storeData:(UCARMonitorNewStoreCommonInfo *)data {
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:data];
    
    if (!archivedData) {
        // 附加描述
        NSString *otherDesc = [NSString stringWithFormat:@"%@_%@_%@_%@_%@_%@_%@", self.appVersion, self.userID, self.appNameStr, self.sessionID, self.longitude, self.latitude, self.mobile];
        // 日志上报
        [self dataErrorWithClazz:data.class method:@"storeData:" otherDesc:otherDesc];
        return;
    }
    
    dispatch_async(ucar_monitor_new_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            [db executeUpdate:UCARMonitorNewStoreTableInsert, self.appVersion, self.userID, self.appNameStr,
                              self.sessionID, self.longitude, self.latitude, self.mobile, archivedData];
        }];
    });
}

- (void)fetchData:(UCARMonitorStoreFetchData)dataBlock {
    dispatch_async(ucar_monitor_new_store_queue(), ^{
        [self.dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
            // auto-generated row IDs are always greater than zero
            long minID = -1;
            long maxID = -1;
            FMResultSet *rs = [db executeQuery:UCARMonitorNewStoreTableQuery, UCARMonitorStoreDefaultValue];
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

                NSString *appVersion = [rs stringForColumn:@"appVersion"];
                NSString *userID = [rs stringForColumn:@"userID"];
                NSString *appName = [rs stringForColumn:@"appName"];
                NSString *sessionID = [rs stringForColumn:@"sessionID"];
                NSString *longitude = [rs stringForColumn:@"longitude"];
                NSString *latitude = [rs stringForColumn:@"latitude"];
                NSString *mobile = [rs stringForColumn:@"mobile"];
                NSData *data = [rs dataForColumn:@"data"];
                NSDictionary *dict = [self convertData:data
                                            appVersion:appVersion
                                                userID:userID
                                               appName:appName
                                             sessionID:sessionID
                                             longitude:longitude
                                              latitude:latitude
                                                mobile:mobile];
                UCARLoggerVerbose(@"UCARMonitorStore fetchData %@", dict);
                
                if (dict) {
                    [list addObject:dict];
                } else {
                    // 附加描述
                    NSString *otherDesc = [NSString stringWithFormat:@"%@_%@_%@_%@_%@_%@_%@", appVersion, userID, appName, sessionID, longitude, latitude, mobile];
                    // 出错 日志上报 (通过 data.class 可以判断 data 是否为 nil)
                    [self dataErrorWithClazz:data.class method:@"fetchData:" otherDesc:otherDesc];
                }
            }
            dataBlock(list);
            //发送后即删除
            [db executeUpdate:UCARMonitorNewStoreTableDelete, @(minID), @(maxID)];
        }];
    });
}

- (NSDictionary *)convertData:(NSData *)data
                   appVersion:(NSString *)appVersion
                       userID:(NSString *)userID
                      appName:(NSString *)appName
                    sessionID:(NSString *)sessionID
                    longitude:(NSString *)longitude
                     latitude:(NSString *)latitude
                       mobile:(NSString *)mobile {
    UCARMonitorNewStoreCommonInfo *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    info.app_version = appVersion;
    info.user_id = userID;
    info.app_name = appName;
    info.session_id = sessionID;
    info.token_id = sessionID;

    info.longitude = longitude;
    info.latitude = latitude;
    info.mobile = mobile;

    return [info convertSelfToDict];
}

#pragma mark store

- (void)storeDevice:(nonnull NSDictionary *)remark {
    UCARMonitorNewStoreDevice *device = [[UCARMonitorNewStoreDevice alloc] init];
    device.device_remark = [UCARMonitorStore stringFromJSONObject:remark];
    [self storeData:device];
}

- (void)storeEvent:(nonnull NSString *)code remark:(nonnull NSDictionary *)remark {
    UCARMonitorNewStoreEvent *event = [[UCARMonitorNewStoreEvent alloc] init];
    event.event_code = code;
    event.event_remark = [UCARMonitorStore stringFromJSONObject:remark];
    [self storeData:event];
}

- (void)storeRoute:(nonnull NSString *)pageName
            action:(UCARMonitorStoreRouteAction)action
            remark:(nonnull NSDictionary *)remark {
    UCARMonitorNewStoreRoute *route = [[UCARMonitorNewStoreRoute alloc] init];
    route.route_activity_code = pageName;
    route.route_remark = [UCARMonitorStore stringFromJSONObject:remark];
    switch (action) {
        case UCARMonitorStoreRouteActionInto: {
            route.action = @"into";
            route.route_start_time = [UCARMonitorStore getTimeString];
            break;
        }
        case UCARMonitorStoreRouteActionLeave: {
            route.action = @"leave";
            route.route_start_time = @"";
            route.route_end_time = [UCARMonitorStore getTimeString];
            route.route_duration = @"";
            break;
        }
        default:
            break;
    }
    [self storeData:route];
}

- (void)storeException:(nonnull NSString *)code
                 stack:(nonnull NSDictionary *)stack
                remark:(nonnull NSDictionary *)remark {
    UCARMonitorNewStoreException *exception = [[UCARMonitorNewStoreException alloc] init];
    exception.exception_code = code;
    exception.exception_stack = [UCARMonitorStore stringFromJSONObject:stack];
    exception.exception_remark = [UCARMonitorStore stringFromJSONObject:remark];
    [self storeData:exception];
}

- (void)storePerformance:(nonnull NSString *)code remark:(nonnull NSDictionary *)remark {
    UCARMonitorNewStorePerformance *performance = [[UCARMonitorNewStorePerformance alloc] init];
    performance.perf_code = code;
    performance.perf_remark = [UCARMonitorStore stringFromJSONObject:remark];
    [self storeData:performance];
}

- (void)storeDNS:(nonnull NSString *)domain
              IP:(nonnull NSString *)IP
        hijackIP:(nonnull NSString *)hijackIP
          remark:(nonnull NSDictionary *)remark {
    UCARMonitorNewStoreDNS *dns = [[UCARMonitorNewStoreDNS alloc] init];
    dns.device_domain = domain;
    dns.dns_ip = IP;
    dns.dns_hijack_ip = hijackIP;
    dns.dns_remark = [UCARMonitorStore stringFromJSONObject:remark];
    [self storeData:dns];
}

- (void)storeLog:(nonnull NSString *)tag content:(nonnull NSString *)content {
    UCARMonitorNewStoreLog *log = [[UCARMonitorNewStoreLog alloc] init];
    log.log_tag = tag;
    log.log_content = content;
    [self storeData:log];
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
        UCARMonitorNewStoreEvent *event = [[UCARMonitorNewStoreEvent alloc] init];
        event.event_code = code;
        event.event_remark = [UCARMonitorStore stringFromJSONObject:remark];

        event.app_version = self.appVersion;
        event.user_id = self.userID;
        event.app_name = self.appNameStr;
        event.session_id = self.sessionID;
        event.token_id = self.sessionID;

        event.longitude = self.longitude;
        event.latitude = self.latitude;
        event.mobile = self.mobile;

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
