//
//  UCARBaseShare.m
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import "UCARBaseShare.h"
#import "UCARShareConstants.h"
#import <UCARLogger/UCARLogger.h>
#import <SDWebImage/SDWebImageManager.h>

@implementation UCARBaseShare

// 设置 delegate
- (instancetype)initWithDelegate:(id)delegate {
    self = [self init];
    self->_delegate = delegate;
    return self;
}

// init
- (instancetype)init {
    self = [super init];
    
    if (![self isKindOfClass:NSClassFromString(@"UCARShareSMS")]) {
        // 注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURLWithNotification:) name:UCARDMethodHOpenURLNotification object:nil];
    }
    return self;
}

// 接收回调通知
- (void)handleOpenURLWithNotification:(NSNotification*)notification {
    NSURL *url = notification.object;
    [self handleOpenURL:url];
}

// 打开回调
- (void)handleOpenURL:(NSURL*)url {
    UCARLoggerDebug(@"###log: 需要在子类中重写: 打开回调 %@", url);
}

// 是否安装客户端
+ (BOOL)isAppInstalled {
    return NO;
}

// 发起分享
- (NSString*)shareWithItem:(UCARShareItem*)item {
    return @"未知操作";
}

// 图片压缩
- (NSData *)imageCompressWithMaxLength:(NSUInteger)maxLength image:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    CGFloat compressionQuality = 0.5;
    CGFloat minCompressionQuality = 0.01;
    if (imageData.length > maxLength) {
        minCompressionQuality = 0.1;
    }
    
    // 按质量压缩图片
    while (imageData.length > maxLength && compressionQuality > minCompressionQuality) {
        imageData = UIImageJPEGRepresentation(image, compressionQuality);
        compressionQuality *= 0.6;
    }
    
    // 质量压缩不够时，再进行尺寸压缩
    UIImage *resultImage = [UIImage imageWithData:imageData];
    NSUInteger lastDataLength = 0;
    while (imageData.length > maxLength && imageData.length != lastDataLength) {
        lastDataLength = imageData.length;
        CGFloat ratio = (CGFloat)maxLength / imageData.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        // Use image to draw (drawInRect:), image is larger but more compression time
        // Use result image to draw, image is smaller but less compression time
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        imageData = UIImageJPEGRepresentation(resultImage, 1);
    }
    return imageData;
}

// 下载图片
- (void)loadImageWithURLSrtring:(NSString *)URLString completed:(void(^)(UIImage * _Nullable image, NSData * _Nullable data))completedBlock {
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    NSURL *url = [NSURL URLWithString:URLString];
    SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageLowPriority | SDWebImageRefreshCached;
    [manager loadImageWithURL:url options:options progress:NULL completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (completedBlock) {
            completedBlock(image, data);
        }
    }];
}

// removeObserver
- (void)dealloc {
    if (![self isKindOfClass:NSClassFromString(@"UCARShareSMS")]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    UCARLoggerDebug(@"UCARBaseShare - dealloc = %@", self);
}

@end
