//
//  UCARLive_Color.h
//  UCarLive
//
//  Created by 宣佚 on 2017/6/19.
//  Copyright © 2017年 UCarInc. All rights reserved.
//

#ifndef UCARLive_Color_h
#define UCARLive_Color_h

#define UCARLIVE_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define UCARLIVE_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define UCARLIVE_UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UCARLIVE_UIAlphaColorFromRGB(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define UCARLIVE_SCALE (UCARLIVE_SCREEN_WIDTH / 414.0)


#endif /* UCARLive_Color_h */
