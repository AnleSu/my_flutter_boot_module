//
//  UCarMessage.h
//  UCARClientSocket
//
//  Created by  zhangfenglin on 15/9/28.
//  Copyright (c) 2015年  zhangfenglin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt8, UCARMessageType) {
    UCARMessageTypeHeartBeatRequest = 0,    // 心跳请求
    UCARMessageTypeHeartBeatResponse,       // 心跳回应
    UCARMessageTypeServerMessage,           // 消息请求
    UCARMessageTypeServerMessageResponse,   // 消息回应
    UCARMessageTypeConnectSuccessRequest,   // 连接成功
    UCARMessageTypeConnectSuccessResponse,  // 连接回应（保留）
    UCARMessageTypeConnectionCloseRequest,  // 关闭请求
    UCARMessageTypeConnectionCloseResponse, // 关闭回应（保留）
    UCARMessageTypeError,                   // 错误的消息类型
    UCARMessageTypeSessionStartRequest,     // 建立会话请求（保留）
    UCARMessageTypeSessionStartResponse,    // 建立会话响应（保留）
    UCARMessageTypeSessionCloseRequest,     // 关闭会话请求（保留）
    UCARMessageTypeSessionCloseResponse,    // 关闭会话响应（保留）
};

typedef NS_ENUM(UInt8, UCARBusinessType) {
    UCARBusinessTypeCommon = 0,
    UCARBusinessTypeOrderChanged = 2,
    UCARBusinessTypeDriverPositionChanged = 3,
    UCARBusinessTypeRecharge = 4,
    UCARBusinessTypeMKTDispatch = 15, //派单页营销活动
    UCARBusinessTypeTaxiDriverChangePayType = 16,
    UCARBusinessTypeTaxiNotifyDriverNum = 17, //派单中通知出租车总数量
    UCAR_PAY_FINISH = 22,                     ///自动结算完成
};

@interface UCarMessage : NSObject
// 消息版本
@property (nonatomic, assign) UInt8 version;

// 消息类型
@property (nonatomic, assign) UCARMessageType type;

// 消息实体
@property (nonatomic, copy) NSString *message;

// 自定义业务类型
@property (nonatomic, assign) UInt8 businessType;

// 设备的uuid（Universally Unique Identifier）
@property (nonatomic, copy) NSString *uuid;

@end
