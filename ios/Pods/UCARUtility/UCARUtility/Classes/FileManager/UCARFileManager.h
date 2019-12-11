//
//  UCARFileManager.h
//  Pods
//
//  Created by linux on 18/11/26.
//
//

#import <Foundation/Foundation.h>

/**
 文件写入路径规范
 @note 目前所有文件路径均不支持 iCloud 同步，用户数据与程序数据存储于同一位置
 */
@interface UCARFileManager : NSObject

/**
 app数据路径，用于存放app数据，不会被iCloud同步

 @return app data path
 @note <Application_Data>/Library/Application Support/ucar/
 */
+ (NSString *)appDataDirectoryPath;

/**
 cache路径，用于存放cache文件

 @return cache path
 @note 这个目录中的文件会被系统随机删除，非缓存不建议使用
 */
+ (NSString *)cachesDirectoryPath;

/**
 temp路径，用于存放临时文件

 @return tmp path
 */
+ (NSString *)tmpDirectoryPath;

/**
 app数据路径，用于存放app数据，不会被iCloud同步

 @return app data url
 @note <Application_Data>/Library/Application Support/ucar/
 */
+ (NSURL *)appDataDirectoryURL;

/**
 cache路径，用于存放cache文件

 @return cache url
 @note 这个目录中的文件会被系统随机删除，非缓存不建议使用
 */
+ (NSURL *)cachesDirectoryURL;

/**
 temp路径，用于存放临时文件

 @return tmp url
 @note 程序不运行时，这个目录中的文件可能会被系统删除，建议仅用于临时文件
 */
+ (NSURL *)tmpDirectoryURL;

@end
