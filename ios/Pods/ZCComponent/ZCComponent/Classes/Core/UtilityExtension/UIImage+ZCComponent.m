//
//  UIImage+UCARUIKit.m
//  Pods-ZCComponent_Example
//
//  Created by 郑熙 on 2019/4/25.
//

#import "UIImage+ZCComponent.h"
#import <objc/runtime.h>

static const void *completeBlockKey = &completeBlockKey;
static const void *failBlockKey = &failBlockKey;

@interface UIImage ()

@property (nonatomic, copy) void (^completeBlock)(void);

@property (nonatomic, copy) void (^failBlock)(void);

@end

@implementation UIImage (ZCComponent)

+ (UIImage * _Nonnull)imageWithColor:(UIColor * _Nonnull)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage * _Nonnull)blurImageWithBlur:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 50);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

+ (UIImage *)imageWithPDF:(id)dataOrPath {
    return [self imageWithPDF:dataOrPath resize:NO size:CGSizeZero];
}

+ (UIImage *)imageWithPDF:(id)dataOrPath size:(CGSize)size {
    return [self imageWithPDF:dataOrPath resize:YES size:size];
}

+ (UIImage *)imageWithPDF:(id)dataOrPath resize:(BOOL)resize size:(CGSize)size {
    CGPDFDocumentRef pdf = NULL;
    if ([dataOrPath isKindOfClass:[NSData class]]) {
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)dataOrPath);
        pdf = CGPDFDocumentCreateWithProvider(provider);
        CGDataProviderRelease(provider);
    } else if ([dataOrPath isKindOfClass:[NSString class]]) {
        pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:dataOrPath]);
    }
    if (!pdf) return nil;
    
    CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
    if (!page) {
        CGPDFDocumentRelease(pdf);
        return nil;
    }
    
    CGRect pdfRect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    CGSize pdfSize = resize ? size : pdfRect.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, pdfSize.width * scale, pdfSize.height * scale, 8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    if (!ctx) {
        CGColorSpaceRelease(colorSpace);
        CGPDFDocumentRelease(pdf);
        return nil;
    }
    
    CGContextScaleCTM(ctx, scale, scale);
    CGContextTranslateCTM(ctx, -pdfRect.origin.x, -pdfRect.origin.y);
    CGContextDrawPDFPage(ctx, page);
    CGPDFDocumentRelease(pdf);
    
    CGImageRef image = CGBitmapContextCreateImage(ctx);
    UIImage *pdfImage = [[UIImage alloc] initWithCGImage:image scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(image);
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    return pdfImage;
}

- (UIImage *)imageByTintColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    [color set];
    UIRectFill(rect);
    [self drawAtPoint:CGPointMake(0, 0) blendMode:kCGBlendModeDestinationIn alpha:1];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark -

/**
 *  保存相册
 *
 *  @param completeBlock 成功回调
 *  @param failBlock 出错回调
 */
- (void)savedToAlbum:(void (^)(void))completeBlock failBlock:(void (^)(void))failBlock {
    UIImageWriteToSavedPhotosAlbum(self, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    self.completeBlock = completeBlock;
    self.failBlock = failBlock;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        if (self.completeBlock != nil) self.completeBlock();
    } else {
        if (self.failBlock != nil) self.failBlock();
    }
}

/*
 *  模拟成员变量
 */
- (void (^)(void))failBlock {
    return objc_getAssociatedObject(self, failBlockKey);
}
- (void)setfailBlock:(void (^)(void))failBlock {
    objc_setAssociatedObject(self, failBlockKey, failBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void (^)(void))completeBlock {
    return objc_getAssociatedObject(self, completeBlockKey);
}

- (void)setcompleteBlock:(void (^)(void))completeBlock {
    objc_setAssociatedObject(self, completeBlockKey, completeBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
