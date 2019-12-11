//
//  UCARMonitorUploader.m
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import "UCARMonitorUploader.h"
#import "UCARMonitorConstants.h"
#import <UCARClientSocket/UCARClientSocket.h>
#import <UCARClientSocket/UCarMessage.h>
#import <UCARClientSocket/UCarMessageUtil.h>
#import <UCARUtility/UCARUtility.h>
#import <UCARLogger/UCARLogger.h>

@interface UCARMonitorUploader () <UCARClientSocketDelegate>

@property (nonatomic) UCarMessageUtil *messageUtil;
@property (nonatomic) UCARClientSocket *socket;

@end

@implementation UCARMonitorUploader

- (instancetype)init {
    self = [super init];
    if (self) {

        _socketConnected = NO;

        _socket = [[UCARClientSocket alloc] initWithDelegate:self];
        _socket.useAutoSendMsg = YES;
        _socket.needSupportIpv6IfUseIpConnectDirectly = YES;
        _socket.timeout = 50.0;

        _sessionID = @"";
        _messageUtil = [[UCarMessageUtil alloc] init];

        NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
        NSString *bundlePath = [selfBundle pathForResource:@"UCARMonitor" ofType:@"bundle"];
        NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
        NSString *configPath = [resourceBundle pathForResource:@"ucarmonitorconfig" ofType:@"plist"];
        NSDictionary *httpConfig = [NSDictionary dictionaryWithContentsOfFile:configPath];
        NSString *envKey = [UCAREnvConfig getCurrentEnvKey];
        NSDictionary *currentConfig = httpConfig[envKey];
        _host = currentConfig[@"domain"];
        _port = [currentConfig[@"port"] intValue];
        [self connectHost];
    }
    return self;
}

- (void)connectHost {
    _socket.host = _host;
    _socket.port = _port;
    [_socket createConnect];
}

- (void)stopUpload {
    [_socket disConnect];
}

- (void)fetchStoreData {
    [self.dataSource fetchData:^(NSArray *_Nullable list) {
        UCARLoggerVerbose(@"UCARMonitorUploader fetchStoreData %@", list);
        if (list.count > 0) {
            [self sendData:list];
        }
    }];
}

- (void)sendData:(NSArray *)data {
    
    //此处未做错误处理，出错时jsonStr=nil，后面会处理这种情况
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    UCarMessage *messageDTO = [[UCarMessage alloc] init];
    messageDTO.uuid = _sessionID;
    messageDTO.type = UCARMessageTypeServerMessage;
    messageDTO.businessType = 0;
    messageDTO.message = jsonStr;
    [_socket writeData:[_messageUtil encodeMessage:messageDTO withKey:UCARMonitorUploader_AES128]];
}

#pragma mark delegate
- (void)didReadData:(NSData *)data withTag:(long)tag {
    UCARLoggerDebug(@"didReadData");
}
- (void)didWriteDataWithTag:(long)tag {
    UCARLoggerDebug(@"didWriteDataWithTag");
}

- (NSData *)getMgsData {
    [self fetchStoreData];
    UCarMessage *messageDTO = [[UCarMessage alloc] init];
    messageDTO.uuid = _sessionID;
    messageDTO.businessType = 0;
    messageDTO.type = UCARMessageTypeHeartBeatRequest;
    messageDTO.message = @"heartbeat";
    return [_messageUtil encodeMessage:messageDTO withKey:UCARMonitorUploader_AES128];
}

- (void)didConnect {
    _socketConnected = YES;

    UCARLoggerDebug(@"UCARMonitorUploader didConnect");
    UCarMessage *messageDTO = [[UCarMessage alloc] init];
    messageDTO.uuid = _sessionID;
    messageDTO.type = UCARMessageTypeConnectSuccessRequest;
    messageDTO.businessType = 0;
    messageDTO.message = [NSString stringWithFormat:@"connect%@", _sessionID];
    [_socket writeData:[_messageUtil encodeMessage:messageDTO withKey:UCARMonitorUploader_AES128]];
}

- (void)didDisConnect {
    _socketConnected = NO;

    UCARLoggerDebug(@"UCARMonitorUploader didDisConnect");
}

@end
