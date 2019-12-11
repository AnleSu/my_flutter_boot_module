//
//  YCCMacroUI.h
//  YCCPlatform
//
//  Created by 闫子阳 on 2017/12/27.
//  Copyright © 2017年 UCar. All rights reserved.
//

#ifndef OCRMacroUI_h
#define OCRMacroUI_h

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define REFERENCE_SCREEN_WIDTH     (375.0)
#define SCALE                      (kScreenWidth/REFERENCE_SCREEN_WIDTH)
#define RELATIVEVALUE(value)       (value * SCALE)
#endif /* CMTMacroUI_h */
