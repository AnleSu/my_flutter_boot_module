//
//  UCARFileManager.m
//  Pods
//
//  Created by linux on 18/11/26.
//
//

#import "UCARFileManager.h"
#import <UCARLogger/UCARLogger.h>

@interface UCARFileManager ()

@end

@implementation UCARFileManager

+ (NSString *)appDataDirectoryPath {
    NSArray<NSString *> *paths =
        NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *appDataPath = [path stringByAppendingPathComponent:@"ucar"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if ([fileManager fileExistsAtPath:appDataPath isDirectory:&isDirectory]) {
        if (!isDirectory) {
            [fileManager removeItemAtPath:path error:nil];
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    } else {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self addSkipBackupAttributeToItemAtPath:appDataPath];
    return appDataPath;
}

+ (NSString *)cachesDirectoryPath {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

+ (NSString *)tmpDirectoryPath {
    return NSTemporaryDirectory();
}

+ (NSURL *)appDataDirectoryURL {
    NSString *path = [self appDataDirectoryPath];
    return [NSURL fileURLWithPath:path isDirectory:YES];
}

+ (NSURL *)cachesDirectoryURL {
    NSArray<NSURL *> *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                                    inDomains:NSUserDomainMask];
    return [URLs lastObject];
}

+ (NSURL *)tmpDirectoryURL {
    NSString *path = NSTemporaryDirectory();
    return [NSURL fileURLWithPath:path isDirectory:YES];
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString {
    NSURL *URL = [NSURL fileURLWithPath:filePathString isDirectory:YES];
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);

    NSError *error = nil;
    BOOL success = [URL setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        UCARLoggerDebug(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
