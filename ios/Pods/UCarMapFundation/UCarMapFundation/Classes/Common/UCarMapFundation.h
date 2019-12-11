//
//  UCarMapFundation.h
//  UCarMapFundation
//
//  Created by huangyi on 3/15/17.
//  Copyright © 2017 UCar. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for UCarMapFundation.
FOUNDATION_EXPORT double UCarMapFundationVersionNumber;

//! Project version string for UCarMapFundation.
FOUNDATION_EXPORT const unsigned char UCarMapFundationVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <UCarMapFundation/PublicHeader.h>
#import <UCarMapFundation/UCarMapTypes.h>


extern NSString* const AMAP_KEY;
extern NSString* const BAIDU_MAP_KEY;

@interface UCarMapFundation : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) NSMutableDictionary* keys;

@end

