//
//  UCARUIKitTools.m
//  UCARUIKit
//
//  Created by KouArlen on 16/3/3.
//  Copyright © 2016年 Arlen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCARUIKitTools.h"

UIColor* UCAR_ColorFromHexStringAndAlpha(NSString *hexString, CGFloat alpha)
{
    unsigned rgbValue = 0;
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0f green:((rgbValue & 0xFF00) >> 8)/255.0f blue:(rgbValue & 0xFF)/255.0f alpha:alpha];
}

UIColor* UCAR_ColorFromHexString(NSString *hexString)
{
    return UCAR_ColorFromHexStringAndAlpha(hexString, 1.0);
}

CGFloat UCAR_ViewZoomRatio(void)
{
    static CGFloat UCARViewZoomRatio = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UCARViewZoomRatio = [UIScreen mainScreen].bounds.size.width / 414;
    });
    return UCARViewZoomRatio;
}

UIView* UCAR_FindFirstResponderInView(UIView *view)
{
    if ([view isFirstResponder])
    {
        return view;
    }
    for (UIView *subview in view.subviews)
    {
        UIView *responder = UCAR_FindFirstResponderInView(subview);
        if (responder)
        {
            return responder;
        }
    }
    return nil;
}


void UCAR_ResignFirstResponderFromView(UIView *view)
{
    UIView *firstResponder = UCAR_FindFirstResponderInView(view);
    if (firstResponder) {
        [firstResponder resignFirstResponder];
    }
}


@implementation UCARUIKitTools

+ (UIImage *)imageNamed:(NSString *)name
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [frameworkBundle pathForResource:@"UCARUIKit" ofType:@"bundle"];
    if (bundlePath) {
        NSBundle *assetBundle = [NSBundle bundleWithPath:bundlePath];
        UIImage *image = [UIImage imageNamed:name inBundle:assetBundle compatibleWithTraitCollection:nil];
        return image;
    }
    return nil;
}

+ (NSBundle *)bundleNamed:(NSString *)name
{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [frameworkBundle pathForResource:name ofType:@"bundle"];
    if (bundlePath) {
        NSBundle *assetBundle = [NSBundle bundleWithPath:bundlePath];
        return assetBundle;
    }
    return nil;
}

@end
