//
//  BaiduCoordinateEncriptor.m
//  UCar
//
//  Created by huangyi on 8/17/16.
//  Copyright © 2016 huangyi. All rights reserved.
//

#import "BaiduCoordinateEncriptor.h"

@implementation BaiduCoordinateEncriptor

+ (CLLocationCoordinate2D)decript:(CLLocationCoordinate2D)coord
{
    CLLocationCoordinate2D result = { 0 };
    double x = coord.longitude - 0.0065;
    double y = coord.latitude - 0.006;
    double z = sqrt( x * x + y * y ) - 0.00002 * sin( y * M_PI );
    double theta = atan2( y, x ) - 0.000003 * cos( x * M_PI );
    result.longitude = z * cos( theta );
    result.latitude = z * sin( theta );
    return result;
}

+ (CLLocationCoordinate2D)encript:(CLLocationCoordinate2D)coord
{
    CLLocationCoordinate2D result = { 0 };
    double x = coord.longitude;
    double y = coord.latitude;
    double z = sqrt( x * x + y * y ) + 0.00002 * sin( y * M_PI );
    double theta = atan2( y, x ) + 0.000003 * cos( x * M_PI );
    result.longitude = z * cos( theta ) + 0.0065;
    result.latitude = z * sin( theta ) + 0.006;
    return result;
}

@end
