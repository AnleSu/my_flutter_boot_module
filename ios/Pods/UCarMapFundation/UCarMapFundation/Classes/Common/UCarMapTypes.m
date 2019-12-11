//
//  UCarMapTypes.m
//  UCar
//
//  Created by huangyi on 8/29/16.
//  Copyright © 2016 huangyi. All rights reserved.
//

#import "UCarMapTypes.h"
#import "BaiduCoordinateEncriptor.h"

static UCarMapImplementType MapType;
@implementation UCarMapType

+ (void)setMapType:(UCarMapImplementType) type
{
    MapType = type;
}

+ (UCarMapImplementType)getMapType
{
    return  MapType;
}

@end

@implementation UCarMapCoordinate
@synthesize amapCoordinate;
@synthesize baiduCoordinate;

+ (instancetype)coordinateWithCoordinate:(UCarMapCoordinate*)coord
{
    UCarMapCoordinate* instance = [[UCarMapCoordinate alloc] init];
    instance.amapCoordinate = coord.amapCoordinate;
    return instance;
}

- (instancetype)copyWithZone:(struct _NSZone *)zone
{
    UCarMapCoordinate* instance = [UCarMapCoordinate allocWithZone:zone];
    instance.amapCoordinate = amapCoordinate;
    return instance;
}

- (void)setAmapCoordinate:(CLLocationCoordinate2D)coordinate
{
    amapCoordinate = coordinate;
    baiduCoordinate = [BaiduCoordinateEncriptor encript:coordinate];
}

- (void)setBaiduCoordinate:(CLLocationCoordinate2D)coordinate
{
    baiduCoordinate = coordinate;
    amapCoordinate = [BaiduCoordinateEncriptor decript:baiduCoordinate];
}

- (CLLocationCoordinate2D)coordinateForImplementType:(UCarMapImplementType)type
{
    if ( type == UCarMapImplementType_Baidu )
    {
        return baiduCoordinate;
    }
    else
    {
        return amapCoordinate;
    }
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate forImplementType:(UCarMapImplementType)type
{
    if ( type == UCarMapImplementType_Baidu )
    {
        self.baiduCoordinate = coordinate;
    }
    else
    {
        self.amapCoordinate = coordinate;
    }
}

- (CLLocationCoordinate2D)coordinate
{
    if ( [UCarMapType getMapType] == UCarMapImplementType_Baidu )
    {
        return baiduCoordinate;
    }
    else
    {
        return amapCoordinate;
    }
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    if ( [UCarMapType getMapType] == UCarMapImplementType_Baidu )
    {
        self.baiduCoordinate = coordinate;
    }
    else
    {
        self.amapCoordinate = coordinate;
    }
}

- (CLLocationDistance)distanceFrom:(UCarMapCoordinate *) coord {
    CLLocation *first = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    CLLocation *second = [[CLLocation alloc] initWithLatitude:coord.coordinate.latitude longitude:coord.coordinate.longitude];
    return [first distanceFromLocation:second];
}

@end

@implementation UCarMapRegion

@synthesize center;
@synthesize spanLat, spanLong;

+ (instancetype) regionWithRegion:(UCarMapRegion*)region
{
    UCarMapRegion* newRegion = [[UCarMapRegion alloc] init];
    newRegion.center.amapCoordinate = region.center.amapCoordinate;
    newRegion.spanLat = region.spanLat;
    newRegion.spanLong = region.spanLong;
    return newRegion;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        center = [[UCarMapCoordinate alloc] init];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ( object == self )
    {
        return YES;
    }
    if ( ![object isKindOfClass:[UCarMapRegion class]] )
    {
        return NO;
    }
    UCarMapRegion* obj = (UCarMapRegion*)object;
    if ( center.amapCoordinate.latitude != obj.center.amapCoordinate.latitude )
    {
        return NO;
    }
    if ( center.amapCoordinate.longitude != obj.center.amapCoordinate.longitude )
    {
        return NO;
    }
    if ( spanLat != obj.spanLat )
    {
        return NO;
    }
    if ( spanLong != obj.spanLong )
    {
        return NO;
    }
    return YES;
}
@end

@implementation UCarMapPathStep
@end


@implementation UCarMapPath
@synthesize steps;

@end


@implementation UCarMapAddress

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        _childPoi = [[NSMutableArray alloc] init];
        _extraInfo = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end

@implementation UCarMapLocation
@end

@implementation UCarMapBusline
@end

@implementation UCarMapSegment
@end

@implementation UCarMapTransit
@end
