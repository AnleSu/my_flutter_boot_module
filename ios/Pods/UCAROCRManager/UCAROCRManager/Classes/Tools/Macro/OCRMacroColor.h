//
//  YCCMacroColor.h
//  YCCPlatform
//
//  Created by 闫子阳 on 2017/12/27.
//  Copyright © 2017年 UCar. All rights reserved.
//

#ifndef OCRMacroColor_h
#define OCRMacroColor_h

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//RGB color macro with alpha
#define UIAlphaColorFromRGB(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:a]

#endif /* YCCMacroColor_h */
