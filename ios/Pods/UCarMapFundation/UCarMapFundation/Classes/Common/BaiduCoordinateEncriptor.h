//
//  BaiduCoordinateEncriptor.h
//  UCar
//
//  Created by huangyi on 8/17/16.
//  Copyright © 2016 huangyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BaiduCoordinateEncriptor : NSObject

/**
 *  Decript baidu coordinate to standard coordinate
 */
+ (CLLocationCoordinate2D)decript:(CLLocationCoordinate2D)coord;


/**
 *  Encript standard coordinate to baidu coordinate
 */
+ (CLLocationCoordinate2D)encript:(CLLocationCoordinate2D)coord;
@end
