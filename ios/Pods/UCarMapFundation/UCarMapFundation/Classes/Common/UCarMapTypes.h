//
//  UCarMapTypes.h
//  UCar
//
//  Created by huangyi on 8/29/16.
//  Copyright © 2016 huangyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

//此处枚举值与接口保持一致
typedef NS_ENUM(NSInteger ,UCarMapImplementType)
{
    UCarMapImplementType_None = 0
    , UCarMapImplementType_AMap = 1
    , UCarMapImplementType_Baidu = 2
};

typedef enum UCarMapSearchRouteStrategy
{
    UCarMapSearchRouteStrategy_Fastest = 0
    , UCarMapSearchRouteStrategy_Shortest
    , UCarMapSearchRouteStrategy_AvoidTrafficJam

    , UCarMapSearchRouteStrategy_Num
    , UCarMapSearchRouteStrategy_Default = UCarMapSearchRouteStrategy_Fastest
} UCarMapSearchRouteStrategy;

@interface UCarMapType : NSObject

+ (void)setMapType:(UCarMapImplementType) type;
+ (UCarMapImplementType)getMapType;

@end

@interface UCarMapCoordinate : NSObject
@property (nonatomic, assign) CLLocationCoordinate2D            amapCoordinate;     // 高德地图坐标
@property (nonatomic, assign) CLLocationCoordinate2D            baiduCoordinate;    // 百度地图坐标
@property (nonatomic, readwrite) CLLocationCoordinate2D         coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate forImplementType:(UCarMapImplementType)type;
- (CLLocationCoordinate2D)coordinateForImplementType:(UCarMapImplementType)type;
- (CLLocationDistance)distanceFrom:(UCarMapCoordinate *) coord;

+ (instancetype)coordinateWithCoordinate:(UCarMapCoordinate*)coord;
@end

@interface UCarMapRegion : NSObject 
@property (nonatomic, readonly) UCarMapCoordinate*              center;
@property (nonatomic, assign) double                            spanLat;
@property (nonatomic, assign) double                            spanLong;

+ (instancetype) regionWithRegion:(UCarMapRegion*)region;
@end

@interface UCarMapPathStep : NSObject
@property (nonatomic, strong) NSArray<UCarMapCoordinate*>*      coordinates;
@property (nonatomic, assign) double                            distance;
@property (nonatomic, strong) NSString*                         road;
@property (nonatomic, strong) NSString*                         instruction;
@end

@interface UCarMapPath : NSObject
@property (nonatomic, strong) NSArray*                          steps;
@property (nonatomic, assign) NSInteger                         distance;
@property (nonatomic, assign) NSInteger                         duration;
@end

@interface UCarMapAddress : NSObject
@property (nonatomic, strong) NSString*                         cityName;
@property (nonatomic, strong) NSString*                         district;
@property (nonatomic, strong) NSString                          *sName;
@property (nonatomic, strong) NSString*                         addressName;
@property (nonatomic, strong) NSString*                         addressDetail;
@property (nonatomic, strong) UCarMapCoordinate*                coordinate;
@property (nonatomic, assign) NSInteger                         distance;
@property (nonatomic, strong) NSString*                         uid;
@property (nonatomic, strong) NSString*                         type;
@property (nonatomic, strong) NSString*                         citycode;
@property (nonatomic, strong) NSString*                         province;
@property (nonatomic, strong) NSString*                         street;
@property (nonatomic, strong) NSString*                         number;//高德取number，百度取street_number;
@property (nonatomic, strong) NSString*                         uniqueID;//高德取cityCode, 百度取cityName;
@property (nonatomic, strong) NSString*                         formattedAddress;
@property (nonatomic, strong) NSMutableArray                    *childPoi;
@property (nonatomic, assign) BOOL                              isCurrentCity;
@property (nonatomic, strong) NSString                          *distanceDisp;
@property (nonatomic, strong) NSMutableDictionary               *extraInfo;
@end

@interface UCarMapLocation : NSObject
@property (nonatomic, assign) CLLocationDistance                altitude;
@property (nonatomic, assign) CLLocationAccuracy                accuracy;
@property (nonatomic, copy) UCarMapCoordinate*                  coordinate;
@property (nonatomic, assign) CLLocationDirection               heading;
@property (nonatomic, assign) CLLocationSpeed                   speed;
@property (nonatomic, copy) NSDate*                             timestamp;
@end

@interface UCarMapBusline : NSObject
@property (nonatomic, strong) NSString*                         type;
@property (nonatomic, strong) NSString*                         name;
@property (nonatomic, assign) CGFloat                           distance;
@property (nonatomic, assign) NSInteger                         busStopCount;
@property (nonatomic, strong) NSArray<UCarMapCoordinate*>*      coordinates;
@property (nonatomic, strong) NSString*                         departureStopName;
@property (nonatomic, strong) NSString*                         arrivalStopName;
@end

@interface UCarMapSegment : NSObject
@property (nonatomic, strong) UCarMapPath*                      walking;
@property (nonatomic, strong) NSArray*                          buslines;
@end

@interface UCarMapTransit : NSObject
@property (nonatomic, strong) NSArray*                          segments;
@property (nonatomic, assign) NSInteger                         walkingDistance;
@property (nonatomic, assign) NSInteger                         distance;
@property (nonatomic, assign) NSInteger                         duration;
@end
