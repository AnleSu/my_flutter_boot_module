//
//  UCARUIKitTools.h
//  UCARUIKit
//
//  Created by KouArlen on 16/3/3.
//  Copyright © 2016年 Arlen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  UI所给标注图相对当前屏幕的缩放比例
 *
 *  @return view的缩放比例
 */
FOUNDATION_EXPORT CGFloat UCAR_ViewZoomRatio(void);

/*
 此方法来自三方库https://github.com/bennyguitar/Colours
 此种方式并无特别之处，仅为了避免使用宏
 */
FOUNDATION_EXPORT UIColor* UCAR_ColorFromHexString(NSString *hexString);
FOUNDATION_EXPORT UIColor* UCAR_ColorFromHexStringAndAlpha(NSString *hexString, CGFloat alpha);

FOUNDATION_EXPORT UIView* UCAR_FindFirstResponderInView(UIView *view);
FOUNDATION_EXPORT void UCAR_ResignFirstResponderFromView(UIView *view);

@interface UCARUIKitTools : NSObject

+ (UIImage *)imageNamed:(NSString *)name;
+ (NSBundle *)bundleNamed:(NSString *)name;

@end
