//
//  UCAROCRPlatformContext.m
//  Pods-UCAROCRManager_Example
//
//  Created by Link on 2019/8/9.
//

#import "UCAROCRPlatformContext.h"
#import <UIKit/UIKit.h>

@implementation UCAROCRPlatformContext
#pragma mark - Life cycle
+ (instancetype)shareInstance {
    static UCAROCRPlatformContext *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}

- (instancetype)copyWithZone:(struct _NSZone *)zone {
    return [UCAROCRPlatformContext shareInstance];
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

// 提供获取图片方法
+ (UIImage *)imageNamed:(NSString *)name {
    UIImage *image = nil;
    [self getCurrentBundle];
    
    if (name) {
        image = [UIImage imageNamed:name inBundle:[self getCurrentBundle] compatibleWithTraitCollection:nil];
    }
    //else cont.
    
    return image;
}

// 提供资源Bundle对象
+ (NSBundle *)getCurrentBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"UCAROCRManager" withExtension:@"bundle"];
    NSBundle *curBundle = [NSBundle bundleWithURL:url];
    return curBundle;
}

@end
