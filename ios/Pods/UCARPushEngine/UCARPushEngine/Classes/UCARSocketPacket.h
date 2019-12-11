//
//  UCARSocketPacket.h
//  UCARPushDemo
//
//  Created by linux on 10/28/16.
//  Copyright © 2016 North. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT const UInt8 UCARPushSDKVersion;

typedef NS_ENUM(UInt8, UCARSocketMessageType) {
    UCARSocketMessageType_HEARTBEAT_REQ = 0,             //心跳请求
    UCARSocketMessageType_HEARTBEAT_RESP = 1,            //心跳回应
    UCARSocketMessageType_MESSAGE_REQ = 2,               //消息请求
    UCARSocketMessageType_MESSAGE_RESP = 3,              //消息回应
    UCARSocketMessageType_CHANNEL_START_NOTIFY_REQ = 4,  //建立通道成功的消息
    UCARSocketMessageType_CHANNEL_START_NOTIFY_RESP = 5, //建立通道成功的消息(预留)
    UCARSocketMessageType_CHANNEL_CLOSE_NOTIFY_REQ = 6,  //关闭通道的通知消息
    UCARSocketMessageType_CHANNEL_CLOSE_NOTIFY_RESP = 7, //关闭通道的通知消息(预留)
    UCARSocketMessageType_MESSAGE_ERROR = 8,             //错误的消息类型
    UCARSocketMessageType_SESSION_START_REQ = 9,         //会话开始请求
    UCARSocketMessageType_SESSION_START_RESP = 10,       //会话开始响应
    UCARSocketMessageType_SESSION_STOP_REQ = 11,         //会话结束请求
    UCARSocketMessageType_SESSION_STOP_RESP = 12         //会话结束响应
};

typedef NS_ENUM(UInt8, UCARSocketPacketError) {
    UCARSocketPacketErrorDataNil = 0,   // didReadData nil
    UCARSocketPacketErrorDataEmpty = 1, // data length = 0
    UCARSocketPacketErrorNoVersion = 2,
    UCARSocketPacketErrorNoMsgType = 3,
    UCARSocketPacketErrorNoSysType = 4,
    UCARSocketPacketErrorNoBusinessType = 5,
    UCARSocketPacketErrorNoLevel = 6,
    UCARSocketPacketErrorNoIsGzip = 7,
    UCARSocketPacketErrorNoUuidLength = 8,
    UCARSocketPacketErrorNoUuid = 9,
    UCARSocketPacketErrorNoContentLength = 10,
    UCARSocketPacketErrorNoContent = 11,
    UCARSocketPacketErrorJSONParseFail = 12

};
@class UCARSocketPacket;

/**
 解析完成回调

 @param packet 解析后的包
 */
typedef void (^UCARSocketPacketParseFinishBlock)(UCARSocketPacket *packet);

/**
 UCARSocketPacket，push包实例
 @discussion socket包文档链接：http://wiki.10101111.com/pages/viewpage.action?pageId=34996747
 */
@interface UCARSocketPacket : NSObject

/**
 push协议版本号
 @note SDK保留字段，不可更改
 */
@property (nonatomic, readonly) UInt8 version;

/**
 消息类型
 */
@property (nonatomic, readonly) UCARSocketMessageType msgType;

/**
 业务类型
 */
@property (nonatomic) UInt8 businessType;

/**
 push包 ID
 */
@property (nonatomic) NSString *UUID;

/**
 业务系统类型，保留字段
 */
@property (nonatomic, readonly) UInt8 sysType;

/**
 消息级别
 @note 普通消息设置为1，打点消息设置为3，手机端暂不使用其他值
 */
@property (nonatomic) UInt8 level;

/**
 是否压缩，保留字段
 */
@property (nonatomic, readonly) UInt8 isGzip;

/**
 消息内容
 */
@property (nonatomic) NSString *content;

/**
 解析数据时占用的大小，用于解决粘包问题
 @note never set this
 */
@property (nonatomic, assign) NSUInteger dataLength;

/**
 解包

 @param data 原始数据
 @param key 解密密钥
 @return a SocketPacket Instance
 */
+ (instancetype)socketPacketWithData:(NSData *)data withDecryptKey:(NSString *)key;

/**
 尝试解包并返回多余数据

 @param data 原始数据
 @param key 解密密钥
 @param finishBlock 解包完成回调
 @return 解析后剩余的数据，可能为nil
 @discussion 主要用于解决粘包及断包问题
 */
+ (NSData *)filterSocketPacketsWithData:(NSData *)data
                         withDecryptKey:(NSString *)key
                            finishBlock:(UCARSocketPacketParseFinishBlock)finishBlock;

/**
 初始化一个包，用于封包

 @param messageType 消息类型
 @return a SocketPacket Instance
 */
+ (instancetype)socketPacketWithMessageType:(UCARSocketMessageType)messageType;

/**
 加密包

 @param key 加密密钥
 @return 加密后的数据
 */
- (NSData *)encryptedDataWithEncryptKey:(NSString *)key;

@end
