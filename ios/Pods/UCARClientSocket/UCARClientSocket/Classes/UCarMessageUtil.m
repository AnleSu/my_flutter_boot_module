//
//  UCarMessageUtil.m
//  UCARClientSocket
//
//  Created by  zhangfenglin on 15/9/28.
//  Copyright (c) 2015年  zhangfenglin. All rights reserved.
//

#import "UCarMessageUtil.h"
#import "UCarMessage.h"
#import <UCARUtility/GZipUtil.h>
#import <UCARUtility/NSString+AES.h>

static const NSUInteger MESSAEG_VERSION_LENGTH = 1; // 消息版本长度
static const NSUInteger MESSAEG_LENGTH = 4;         // 消息内容长度
static const NSUInteger MESSAEG_TYPE_LENGTH = 1;    // 消息类型长度
static const NSUInteger BUSINESS_TYPE_LENGTH = 1;   // 业务类型长度
static const NSUInteger UUID_LENGTH = 4;            // 唯一标识长度

static UInt32 swapLittleEndianToBigEndian(UInt32 x) {
    return (((UInt32)(x)&0xff000000) >> 24) | (((UInt32)(x)&0x00ff0000) >> 8) |
           (((UInt32)(x)&0x0000ff00) << 8) | (((UInt32)(x)&0x000000ff) << 24);
}

static UInt32 swapBigEndianToLittleEndian(UInt32 x) {
    return (((UInt32)(x)&0xff000000) >> 24) | (((UInt32)(x)&0x00ff0000) >> 8) |
           (((UInt32)(x)&0x0000ff00) << 8) | (((UInt32)(x)&0x000000ff) << 24);
}

@interface UCarMessageUtil ()
@property (nonatomic, assign) UInt8 *compressedBytes;
@property (nonatomic, assign) NSInteger reseveredMemoryBufferSize;
@end

@implementation UCarMessageUtil

- (id)init {
    if (self = [super init]) {
        _reseveredMemoryBufferSize = 2048;
        _compressedBytes = (UInt8 *)malloc(_reseveredMemoryBufferSize);
    }
    return self;
}

- (void)dealloc {
    if (self.compressedBytes) {
        free(self.compressedBytes);
    }
}

- (NSData *)encodeMessage:(UCarMessage *)msg withKey:(NSString *)KEY_AES128 {
    if (!msg) {
        return nil;
    }

    UInt8 *dataBuffer = NULL;
    UInt8 *originDataBuffer = NULL;
    int bytesSum = 0;

    // 压缩加密消息
    const char *msgString = [msg.message UTF8String];
    NSData *data = [[NSData dataWithBytes:msgString
                                   length:strlen(msgString)] gzCompress];
    NSStringEncoding isoEncoding =
        CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
    NSString *str = [[NSString alloc] initWithBytes:[data bytes]
                                             length:[data length]
                                           encoding:isoEncoding];

    NSMutableString *replacedString = [NSMutableString
        stringWithFormat:@"%@", [NSString AESForEncry:str WithKey:KEY_AES128]];

    NSData *compressedData =
        [replacedString dataUsingEncoding:NSUTF8StringEncoding];

    NSUInteger compressedLength = compressedData.length;

    if (compressedLength > self.reseveredMemoryBufferSize) {
        free(self.compressedBytes);
        self.reseveredMemoryBufferSize = compressedLength;
        self.compressedBytes = (UInt8 *)malloc(self.reseveredMemoryBufferSize);
        memset(self.compressedBytes, 0, self.reseveredMemoryBufferSize);
    } else {
        memset(self.compressedBytes, 0, self.reseveredMemoryBufferSize);
    }

    [compressedData getBytes:self.compressedBytes length:compressedLength];

    // 消息长度和消息内容
    UInt32 msgLen = (UInt32)compressedLength;

    // UUID长度和UUID内容
    const char *uuid = [msg.uuid UTF8String];
    UInt32 uuidLen = 0;
    if (uuid) {
        uuidLen = (UInt32)strlen(uuid);
    }

    bytesSum = MESSAEG_VERSION_LENGTH + MESSAEG_LENGTH + MESSAEG_TYPE_LENGTH +
               BUSINESS_TYPE_LENGTH + UUID_LENGTH + uuidLen + msgLen;
    dataBuffer = (UInt8 *)malloc(bytesSum);
    originDataBuffer = dataBuffer;
    memset(dataBuffer, 0, bytesSum);

    // 消息版本
    dataBuffer[0] = msg.version;
    dataBuffer += MESSAEG_VERSION_LENGTH;

    // 消息类型
    dataBuffer[0] = msg.type;
    dataBuffer += MESSAEG_TYPE_LENGTH;

    // 业务类型
    dataBuffer[0] = msg.businessType;
    dataBuffer += BUSINESS_TYPE_LENGTH;

    // uuid长度
    UInt32 *intAddr = (UInt32 *)dataBuffer;
    UInt32 bigEndianUUIDLen = swapLittleEndianToBigEndian(uuidLen);
    intAddr[0] = bigEndianUUIDLen;
    dataBuffer += UUID_LENGTH;

    // uuid
    memcpy(dataBuffer, uuid, uuidLen);
    dataBuffer += uuidLen;

    // message长度
    intAddr = (UInt32 *)dataBuffer;
    UInt32 bigEndianMsgLen = swapLittleEndianToBigEndian(msgLen);
    intAddr[0] = bigEndianMsgLen;
    dataBuffer += MESSAEG_LENGTH;

    // message
    memcpy(dataBuffer, self.compressedBytes, msgLen);

    NSData *result = [[NSData alloc] initWithBytes:originDataBuffer
                                            length:bytesSum];
    free(originDataBuffer);

    return result;
}

- (UCarMessage *)decodeData:(NSData *)data withKey:(NSString *)KEY_AES128 {
    if (!data || data.length == 0) {
        return nil;
    }

    if (data.length <
        (MESSAEG_VERSION_LENGTH + MESSAEG_LENGTH + MESSAEG_TYPE_LENGTH +
         BUSINESS_TYPE_LENGTH + UUID_LENGTH)) {
        return nil;
    }

    NSUInteger remaindDataLength = data.length;

    UInt8 *buffer = malloc(data.length);
    UInt8 *originalBuffer = buffer;

    memset(buffer, 0, data.length);
    [data getBytes:buffer length:data.length];

    UCarMessage *msg = [[UCarMessage alloc] init];

    // 消息版本
    msg.version = buffer[0];
    buffer += MESSAEG_VERSION_LENGTH;
    remaindDataLength -= MESSAEG_VERSION_LENGTH;

    // 消息类型
    msg.type = buffer[0];
    buffer += MESSAEG_TYPE_LENGTH;
    remaindDataLength -= MESSAEG_TYPE_LENGTH;

    // 业务类型
    msg.businessType = buffer[0];
    buffer += BUSINESS_TYPE_LENGTH;
    remaindDataLength -= BUSINESS_TYPE_LENGTH;

    // UUID长度
    UInt32 *intAddr = (UInt32 *)buffer;
    UInt32 littleEndianLen = swapBigEndianToLittleEndian(intAddr[0]);
    buffer += UUID_LENGTH;
    remaindDataLength -= UUID_LENGTH;

    // UUID内容
    if (littleEndianLen > 0) {
        if (littleEndianLen > (remaindDataLength - MESSAEG_LENGTH)) {
            free(originalBuffer);
            originalBuffer = NULL;
            return nil;
        }

        char *uuid = malloc(littleEndianLen + 1);
        memset(uuid, 0, littleEndianLen + 1);
        memcpy(uuid, buffer, littleEndianLen);
        msg.uuid = [[NSString alloc] initWithUTF8String:uuid];
        free(uuid);
        buffer += littleEndianLen;
        remaindDataLength -= littleEndianLen;
    }

    // 消息长度
    intAddr = (UInt32 *)buffer;
    littleEndianLen = swapBigEndianToLittleEndian(intAddr[0]);
    buffer += MESSAEG_LENGTH;
    remaindDataLength -= MESSAEG_LENGTH;

    // 消息内容
    if (littleEndianLen > 0) {
        // 解密和解压消息
        NSMutableString *replacedString =
            [[NSMutableString alloc] initWithBytes:buffer
                                            length:littleEndianLen
                                          encoding:NSUTF8StringEncoding];

        if (!replacedString) {
            free(originalBuffer);
            originalBuffer = NULL;
            return nil;
        }

        NSString *decryString = [NSString AESForDecry:replacedString
                                              WithKey:KEY_AES128];

        NSStringEncoding isoEncoding =
            CFStringConvertEncodingToNSStringEncoding(
                kCFStringEncodingISOLatin1);
        NSData *decryData = [decryString dataUsingEncoding:isoEncoding];
        NSData *decompressData = [decryData gzDecompress];

        msg.message = [[NSString alloc] initWithData:decompressData
                                            encoding:NSUTF8StringEncoding];
    }

    free(originalBuffer);

    return msg;
}

@end
