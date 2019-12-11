//
//  UCARWebViewBridgeLoader.m
//  UCARJSBridge
//
//  Created by linux on 05/01/2018.
//  Copyright © 2018 UCar. All rights reserved.
//

#import "UCARWebViewBridgeLoader.h"

@interface UCARWebViewBridgeLoader ()

@end

@implementation UCARWebViewBridgeLoader

+ (instancetype)sharedBridge
{
    static UCARWebViewBridgeLoader *bridge = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bridge = [[UCARWebViewBridgeLoader alloc] init];
    });
    return bridge;
}

//- (void)checkVersionAtStart:(YCCStartNewModel *)startNewModel
//{
//    /**
//     比对策略
//     1. 先比较App版本号
//     2. 在比对压缩包版本号
//     ***/
//    NSString *foldVersion = [[NSUserDefaults standardUserDefaults] stringForKey:YCCWebViewBridgeUserDefaultFolderVersionKey];
//    if (![foldVersion isEqualToString:YCCAppVersion]) {
//        //app有更新，直接解压本地包
//        NSString *versionPath = [[NSBundle mainBundle] pathForResource:@"jsbridge" ofType:@"plist"];
//        NSDictionary *versionDict = [NSDictionary dictionaryWithContentsOfFile:versionPath];
//        NSString *fileVersion = versionDict[@"version"];
//        NSString *fileName = versionDict[@"filename"];
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"jsbridge" ofType:@"zip"];
//        [self unarchiveZipFile:filePath fileName:fileName version:fileVersion];
//    }
//
//    if (![Utility isEmptyObj:startNewModel]) {
//        NSString *h5VersionName = startNewModel.h5VersionName;
//        NSString *h5Address = startNewModel.h5Address;
//        if (h5Address) {
//            NSString *localVersion = [[NSUserDefaults standardUserDefaults] stringForKey:YCCWebViewBridgeUserDefaultVersionKey];
//            if (![localVersion isEqualToString:h5VersionName]) {
//                [self checkFilePath:h5Address version:h5VersionName];
//                return;
//            }
//        }
//    }
//}
//
//- (NSString *)jsbridgePath
//{
//    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/jsbridge"];
//}
//
//- (NSString *)unarchivePath
//{
//    return [NSString stringWithFormat:@"%@/%@", [self jsbridgePath], YCCAppVersion];
//}
//
//- (NSString *)folderPath
//{
//    NSString *folderName = [[NSUserDefaults standardUserDefaults] stringForKey:YCCWebViewBridgeUserDefaultFolderNameKey];
//    if (folderName) {
//        return [[self unarchivePath] stringByAppendingPathComponent:folderName];
//    }
//    return nil;
//}
//
//- (void)checkDirectoryPath:(NSString *)path
//{
//    BOOL isDirectory = YES;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
//        if (!isDirectory) {
//            [fileManager removeItemAtPath:path error:nil];
//            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//    } else {
//        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//}
//
//- (void)checkFilePath:(NSString *)downloadURL version:(NSString *)version
//{
//    NSString *fileName = [downloadURL lastPathComponent];
//    NSString *tmpPath = [NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(), fileName];
//
//
//    [self downloadFile:downloadURL toPath:tmpPath version:version];
//}
//
//- (void)downloadFile:(NSString *)urlPath toPath:(NSString *)toPath version:(NSString *)version
//{
//    [[UCARHttpBaseManager sharedManager] downloadFileFromURLString:urlPath toPath:toPath completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//        NSString *fileName = [filePath.lastPathComponent stringByDeletingPathExtension];
//        [self unarchiveZipFile:filePath.path fileName:fileName version:version];
//    }];
//}
//
//- (void)unarchiveZipFile:(NSString *)filePath fileName:(NSString *)fileName version:(NSString *)version
//{
//    [self checkDirectoryPath:[self jsbridgePath]];
//    NSString *unarchivePath = [self unarchivePath];
//    [self checkDirectoryPath:unarchivePath];
//
//    [SSZipArchive unzipFileAtPath:filePath toDestination:unarchivePath overwrite:YES password:nil progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
//        //
//    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
//        if (succeeded) {
//            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
//            [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:YCCWebViewBridgeUserDefaultFolderNameKey];
//            [[NSUserDefaults standardUserDefaults] setObject:YCCAppVersion forKey:YCCWebViewBridgeUserDefaultFolderVersionKey];
//            [[NSUserDefaults standardUserDefaults] setObject:version forKey:YCCWebViewBridgeUserDefaultVersionKey];
//        }
//    }];
//}

@end
