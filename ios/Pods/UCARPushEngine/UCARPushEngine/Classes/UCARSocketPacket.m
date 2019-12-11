//
//  UCARSocketPacket.m
//  UCARPushDemo
//
//  Created by North on 10/28/16.
//  Copyright © 2016 North. All rights reserved.
//

#import "UCARSocketPacket.h"
#import <UCARMonitor/UCARMonitorStore.h>
#import <UCARUtility/UCARUtility.h>

const UInt8 UCARPushSDKVersion = 3;

const NSUInteger UCARUInt8Size = sizeof(UInt8);
const NSUInteger UCARUInt32Size = sizeof(UInt32);

static UInt32 ucar_swapLittleEndianToBigEndian(UInt32 x) {
    return (((UInt32)(x)&0xff000000) >> 24) | (((UInt32)(x)&0x00ff0000) >> 8) | (((UInt32)(x)&0x0000ff00) << 8) |
           (((UInt32)(x)&0x000000ff) << 24);
}

static UInt32 ucar_swapBigEndianToLittleEndian(UInt32 x) {
    return (((UInt32)(x)&0xff000000) >> 24) | (((UInt32)(x)&0x00ff0000) >> 8) | (((UInt32)(x)&0x0000ff00) << 8) |
           (((UInt32)(x)&0x000000ff) << 24);
}

@interface UCARSocketPacket ()

@property (nonatomic, readwrite) UInt8 version;
@property (nonatomic, readwrite) UCARSocketMessageType msgType;
@property (nonatomic, readwrite) UInt8 sysType;
@property (nonatomic, readwrite) UInt8 isGzip;

- (instancetype)initWithMessageType:(UCARSocketMessageType)messageType;

@end
//=========================================

@interface UCARSocketPacketHeartBeat : UCARSocketPacket

@end

@implementation UCARSocketPacketHeartBeat

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        UInt8 version = 1;
        [data getBytes:&version range:NSMakeRange(0, 1)];
        self.version = version;

        UInt8 msgType = 1;
        [data getBytes:&msgType range:NSMakeRange(1, 1)];
        self.msgType = msgType;

        self.dataLength = 2;
    }
    return self;
}

- (NSData *)encryptedDataWithEncryptKey:(NSString *)key {
    NSMutableData *data = [NSMutableData data];
    UInt8 version = self.version;
    [data appendBytes:&version length:UCARUInt8Size];
    UInt8 msgType = self.msgType;
    [data appendBytes:&msgType length:UCARUInt8Size];
    return [data copy];
}

@end

//===================================
@interface UCARSocketPacketResponse : UCARSocketPacket

@end

@implementation UCARSocketPacketResponse

- (instancetype)initWithMessageType:(UCARSocketMessageType)messageType {
    self = [super initWithMessageType:messageType];
    if (self) {
        self.businessType = 1;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        UInt8 version = 1;
        [data getBytes:&version range:NSMakeRange(0, 1)];
        self.version = version;

        UInt8 msgType = 1;
        [data getBytes:&msgType range:NSMakeRange(1, 1)];
        self.msgType = msgType;

        UInt8 uuidLength = 1;
        [data getBytes:&uuidLength range:NSMakeRange(2, 1)];

        NSData *uuidData = [data subdataWithRange:NSMakeRange(3, uuidLength)];
        self.UUID = [[NSString alloc] initWithData:uuidData encoding:NSUTF8StringEncoding];

        UInt8 businessType = 1;
        [data getBytes:&businessType range:NSMakeRange(3 + uuidLength, 1)];
        self.businessType = businessType;

        self.dataLength = uuidLength + 4;
    }
    return self;
}

- (NSData *)encryptedDataWithEncryptKey:(NSString *)key {
    NSMutableData *data = [NSMutableData data];

    UInt8 version = self.version;
    [data appendBytes:&version length:UCARUInt8Size];

    UInt8 msgType = self.msgType;
    [data appendBytes:&msgType length:UCARUInt8Size];

    NSData *uuidData = [self.UUID dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger uuidLength = uuidData.length;
    [data appendBytes:&uuidLength length:UCARUInt8Size];
    [data appendData:uuidData];

    UInt8 businessType = self.businessType;
    [data appendBytes:&businessType length:UCARUInt8Size];

    return [data copy];
}

@end

//================================
@interface UCARSocketPacketNormal : UCARSocketPacket

@end

@implementation UCARSocketPacketNormal

- (instancetype)initWithData:(NSData *)data withDecryptKey:(NSString *)key {
    self = [super init];
    if (self) {
        UInt8 version = 1;
        [data getBytes:&version range:NSMakeRange(0, 1)];
        self.version = version;

        if (data.length <= 2) {
            NSDictionary *error = @{@"msg" : @"NoMsgType", @"errorCode" : @(UCARSocketPacketErrorNoMsgType)};
            [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
            UCARLoggerError(@"SDTS_ERROR NoMsgType %ld %@", data.length, data);
            return nil;
        }
        UInt8 msgType = 1;
        [data getBytes:&msgType range:NSMakeRange(1, 1)];
        self.msgType = msgType;

        if (data.length <= 3) {
            NSDictionary *error = @{@"msg" : @"NoSysType", @"errorCode" : @(UCARSocketPacketErrorNoSysType)};
            [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
            UCARLoggerError(@"SDTS_ERROR NoSysType %ld %@", data.length, data);
            return nil;
        }
        UInt8 sysType = 1;
        [data getBytes:&sysType range:NSMakeRange(2, 1)];
        self.sysType = sysType;

        if (data.length <= 4) {
            NSDictionary *error = @{@"msg" : @"NoBusinessType", @"errorCode" : @(UCARSocketPacketErrorNoBusinessType)};
            [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
            UCARLoggerError(@"SDTS_ERROR NoBusinessType %ld %@", data.length, data);
            return nil;
        }
        UInt8 businessType = 1;
        [data getBytes:&businessType range:NSMakeRange(3, 1)];
        self.businessType = businessType;

        if (data.length <= 5) {
            NSDictionary *error = @{@"msg" : @"NoLevel", @"errorCode" : @(UCARSocketPacketErrorNoLevel)};
            [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
            UCARLoggerError(@"SDTS_ERROR NoLevel %ld %@", data.length, data);
            return nil;
        }
        UInt8 level = 1;
        [data getBytes:&level range:NSMakeRange(4, 1)];
        self.level = level;

        if (data.length <= 6) {
            NSDictionary *error = @{@"msg" : @"NoIsGzip", @"errorCode" : @(UCARSocketPacketErrorNoIsGzip)};
            [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
            UCARLoggerError(@"SDTS_ERROR NoIsGzip %ld %@", data.length, data);
            return nil;
        }
        UInt8 isGzip = 1;
        [data getBytes:&isGzip range:NSMakeRange(5, 1)];
        self.isGzip = isGzip;

        if (data.length <= 7) {
            NSDictionary *error = @{@"msg" : @"NoUuidLength", @"errorCode" : @(UCARSocketPacketErrorNoUuidLength)};
            [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
            UCARLoggerError(@"SDTS_ERROR NoUuidLength %ld %@", data.length, data);
            return nil;
        }
        UInt8 uuidLength = 1;
        [data getBytes:&uuidLength range:NSMakeRange(6, 1)];

        if (data.length <= 7 + uuidLength) {
            NSDictionary *error = @{@"msg" : @"NoUuid", @"errorCode" : @(UCARSocketPacketErrorNoUuid)};
            [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
            UCARLoggerError(@"SDTS_ERROR NoUuid %ld %@", data.length, data);
            return nil;
        }
        NSData *uuidData = [data subdataWithRange:NSMakeRange(7, uuidLength)];
        self.UUID = [[NSString alloc] initWithData:uuidData encoding:NSUTF8StringEncoding];

        if (data.length <= 7 + uuidLength + 4) {
            NSDictionary *error =
                @{@"msg" : @"NoContentLength", @"errorCode" : @(UCARSocketPacketErrorNoContentLength)};
            [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
            UCARLoggerError(@"SDTS_ERROR NoContentLength %ld %@", data.length, data);
            return nil;
        }
        UInt32 contentLength = 1;
        [data getBytes:&contentLength range:NSMakeRange(7 + uuidLength, 4)];
        contentLength = ucar_swapBigEndianToLittleEndian(contentLength);

        if (data.length < contentLength + uuidLength + 11) {
            NSDictionary *error = @{@"msg" : @"NoContent", @"errorCode" : @(UCARSocketPacketErrorNoContent)};
            [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
            UCARLoggerError(@"SDTS_ERROR NoContent %ld %@", data.length, data);
            return nil;
        }
        NSData *contentData = [data subdataWithRange:NSMakeRange(11 + uuidLength, contentLength)];
        NSString *content = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
        self.content = [NSString AESForDecry:content WithKey:key];

        self.dataLength = contentLength + uuidLength + 11;
    }
    return self;
}

- (NSData *)encryptedDataWithEncryptKey:(NSString *)key {
    NSMutableData *data = [NSMutableData data];

    UInt8 version = self.version;
    [data appendBytes:&version length:UCARUInt8Size];

    UInt8 msgType = self.msgType;
    [data appendBytes:&msgType length:UCARUInt8Size];

    UInt8 sysType = self.sysType;
    [data appendBytes:&sysType length:UCARUInt8Size];

    UInt8 businessType = self.businessType;
    [data appendBytes:&businessType length:UCARUInt8Size];

    UInt8 level = self.level;
    [data appendBytes:&level length:UCARUInt8Size];

    UInt8 isGzip = self.isGzip;
    [data appendBytes:&isGzip length:UCARUInt8Size];

    NSData *uuidData = [self.UUID dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger uuidLength = uuidData.length;
    [data appendBytes:&uuidLength length:UCARUInt8Size];
    [data appendData:uuidData];

    NSString *content = [NSString AESForEncry:self.content WithKey:key];
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    UInt32 contentLength = (UInt32)contentData.length;
    UInt32 contentLen = ucar_swapLittleEndianToBigEndian(contentLength);
    [data appendBytes:&contentLen length:UCARUInt32Size];
    [data appendData:contentData];

    return [data copy];
}

@end

//=============================================

@implementation UCARSocketPacket

+ (NSData *)filterSocketPacketsWithData:(NSData *)data
                         withDecryptKey:(NSString *)key
                            finishBlock:(UCARSocketPacketParseFinishBlock)finishBlock {
    if (data.length <= 1) {
        NSDictionary *error = @{@"msg" : @"NoVersion", @"errorCode" : @(UCARSocketPacketErrorNoVersion)};
        [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
        UCARLoggerError(@"SDTS_ERROR NoVersion %ld %@", data.length, data);
        return nil;
    }
    NSUInteger totalLength = data.length;
    NSUInteger parsedLength = 0;
    while (parsedLength < totalLength) {
        NSUInteger leftLength = totalLength - parsedLength;
        NSData *subData = [data subdataWithRange:NSMakeRange(parsedLength, leftLength)];
        UCARSocketPacket *packet = [self socketPacketWithData:subData withDecryptKey:key];
        if (!packet) {
            //解析发生错误，停止解析
            return subData;
        }
        parsedLength += packet.dataLength;
        finishBlock(packet);
    }
    return nil;
}

+ (instancetype)socketPacketWithData:(NSData *)data withDecryptKey:(NSString *)key {
    if (data.length <= 1) {
        NSDictionary *error = @{@"msg" : @"NoVersion", @"errorCode" : @(UCARSocketPacketErrorNoVersion)};
        [[UCARMonitorStore sharedStore] storeEvent:@"SDTS_ERROR" remark:error];
        UCARLoggerError(@"SDTS_ERROR NoVersion %ld %@", data.length, data);
        return nil;
    }
    UInt8 msgType = 1;
    [data getBytes:&msgType range:NSMakeRange(1, 1)];
    switch (msgType) {
        case UCARSocketMessageType_HEARTBEAT_REQ:
        case UCARSocketMessageType_HEARTBEAT_RESP:
            return [[UCARSocketPacketHeartBeat alloc] initWithData:data];
        case UCARSocketMessageType_MESSAGE_RESP:
            return [[UCARSocketPacketResponse alloc] initWithData:data];
        default:
            return [[UCARSocketPacketNormal alloc] initWithData:data withDecryptKey:key];
    }
}

+ (instancetype)socketPacketWithMessageType:(UCARSocketMessageType)messageType {
    switch (messageType) {
        case UCARSocketMessageType_HEARTBEAT_REQ:
        case UCARSocketMessageType_HEARTBEAT_RESP:
            return [[UCARSocketPacketHeartBeat alloc] initWithMessageType:messageType];
        case UCARSocketMessageType_MESSAGE_RESP:
            return [[UCARSocketPacketResponse alloc] initWithMessageType:messageType];
        default:
            return [[UCARSocketPacketNormal alloc] initWithMessageType:messageType];
    }
}

- (instancetype)init {
    return [self initWithMessageType:UCARSocketMessageType_HEARTBEAT_REQ];
}

- (instancetype)initWithMessageType:(UCARSocketMessageType)messageType {
    self = [super init];
    if (self) {
        _version = UCARPushSDKVersion;
        _msgType = messageType;
        _businessType = 0;
        _sysType = 0;
        _level = 1;
        _isGzip = 0;
    }
    return self;
}

- (NSData *)encryptedDataWithEncryptKey:(NSString *)key {
    return nil;
}

@end
