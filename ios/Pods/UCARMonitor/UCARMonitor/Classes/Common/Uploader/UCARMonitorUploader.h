//
//  UCARMonitorUploader.h
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import <Foundation/Foundation.h>


/**
 获取事件数据

 @param data 事件数据
 */
typedef void (^UCARMonitorStoreFetchData)(NSArray *_Nullable data);


/**
 事件数据源
 */
@protocol UCARMonitorUploaderDataSource <NSObject>

@required

/**
 获取数据

 @param dataBlock 获取数据回调
 */
- (void)fetchData:(nonnull UCARMonitorStoreFetchData)dataBlock;

@end


/**
 事件上传器
 */
@interface UCARMonitorUploader : NSObject

/**
 数据源
 */
@property (nonatomic, nullable) id<UCARMonitorUploaderDataSource> dataSource;

/**
 网络请求的uid
 */
@property (nonatomic, nonnull) NSString *sessionID;

/**
 monitor服务器地址
 */
@property (nonatomic, nonnull) NSString *host;

/**
 monitor服务器端口
 */
@property (nonatomic) UInt16 port;

/**
 当前是否可以发送数据
 */
@property (nonatomic, assign) BOOL socketConnected;


/**
 连接服务器
 */
- (void)connectHost;


/**
 停止上传
 */
- (void)stopUpload;


/**
 发送数据

 @param data 数据
 @discussion 用于紧急事件发送
 */
- (void)sendData:(nonnull NSArray *)data;

@end
