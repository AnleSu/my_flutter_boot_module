//
//  UCarMapSearchService.h
//  UCar
//
//  Created by huangyi on 5/31/16.
//  Copyright © 2016 huangyi. All rights reserved.
//

#import <UCarMapFundation/UCarMapFundation.h>

//! Project version number for UCarMapSearchService.
FOUNDATION_EXPORT double UCarMapSearchServiceVersionNumber;

//! Project version string for UCarMapSearchService.
FOUNDATION_EXPORT const unsigned char UCarMapSearchServiceVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <UCarMapSearchService/PublicHeader.h>

typedef enum UCarMapSearchServerceError
{
    UCarMapSearchServerceError_OK = 0
    , UCarMapSearchServerceError_Canceled
    , UCarMapSearchServerceError_NoResult
} UCarMapSearchServerceError;

enum UCarMapSearchPOIType
{
    UCarMapSearchPOIType_Toilet = 0x1
    , UCarMapSearchPOIType_Restaurant = 0x2
    , UCarMapSearchPOIType_Fuel = 0x4
    , UCarMapSearchPOIType_Park = 0x8
    , UCarMapSearchPOIType_SOS = 0x10
    , UCarMapSearchPOIType_VIO = 0x20

    , UCarMapSearchPOIType_All = 0xFFFFFFFF
};

/**
 *  brief:  Like UCarMapService, this class provides basic search service. A static instance is providec by shareInstance.
 *          Directly use the shareInstance is recommended.
 *          However, user can also create new instance.
 *          Each instance can serve only one request at one time. A group of request will be processed with FIFO schedule.
 */
@interface UCarMapSearchService : NSObject
@property (nonatomic, readwrite) UCarMapImplementType   implementType;

/**
 *  @brief  Get the singleton instance.
 */
+ (instancetype)sharedInstance;

/**
 *  @brief  Search a route from origin to destination.
 *
 *  @param origin  The origin of route.
 *  @param destination The destination of route.
 *  @param callback    The callback block when finished.
 *                      The err will be nil if success.
 */
- (__weak id)searchDrivingRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination complete:(void(^)( UCarMapPath* path, NSError* err ))callback;

- (__weak id)searchDrivingRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination withStrategy:(UCarMapSearchRouteStrategy)strategy complete:(void(^)( UCarMapPath* path, NSError* err ))callback;

- (__weak id)searchDrivingRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination wayPoints:(NSArray*)wayPoints withStrategy:(UCarMapSearchRouteStrategy)strategy complete:(void(^)( UCarMapPath* path, NSError* err ))callback;

- (__weak id)searchWalkingRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination complete:(void(^)( UCarMapPath* path, NSError* err ))callback;

- (__weak id)searchTransitRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination city:(NSString *)city nightFlag:(BOOL)nightFlag complete:(void(^)( NSArray<UCarMapTransit*>* transits, NSError* err ))callback;

- (__weak id)searchTransitRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination city:(NSString *)city DestinationCity:(NSString *)destCity nightFlag:(BOOL)nightFlag complete:(void(^)( NSArray<UCarMapTransit*>* transits, NSError* err ))callback;

/**
 *  @brief  Search geocode.
 *
 *  @param cityName     :  The City Name.
 *  @param addressName  :  The Address Name.
 *  @param callback     :    The callback block when finished.
 *      @param address The result. The first one is reverse geocode. The others are nearby POI
 *      @param err     The err will be nil if success.
 */
- (__weak id)searchGeoCode:(NSString*)cityName address:(NSString*)addressName complete:(void(^)( NSArray<UCarMapAddress*>* address, NSError* err ))callback;

/**
 *  @brief  Search reverse geocode.
 *
 *  @param coordinate  The coordinate.
 *  @param callback    The callback block when finished.
 *      @param address The result. The first one is reverse geocode. The others are nearby POI
 *      @param err     The err will be nil if success.
 */
- (__weak id)reverseGeoCode:(UCarMapCoordinate*)coordinate complete:(void(^)( NSArray<UCarMapAddress*>* address, NSError* err ))callback;

/**
 *  @brief  Search POIs nearby.
 *
 *  @param coordinate  The coordinate.
 *  @param callback    The callback block when finished.
 */
- (__weak id)searchPOI:(UCarMapCoordinate*)coordinate complete:(void(^)( NSArray<UCarMapAddress*>* pois, NSError* err ))callback;

- (__weak id)searchPOI:(UCarMapCoordinate*)coordinate poiTypes:(NSInteger)poiTypes complete:(void(^)( NSArray<UCarMapAddress*>* pois, NSError* err ))callback;

- (__weak id)searchPOI:(UCarMapCoordinate*)coordinate poiTypes:(NSInteger)poiTypes distance:(CGFloat)distance pageCount:(NSInteger)count complete:(void(^)( NSArray<UCarMapAddress*>* pois, NSError* err ))callback;


- (__weak id)searchKeyword:(NSString* )keyword cityName:(NSString * )cityname poiType:(NSInteger)types complete:(void(^)( NSArray<UCarMapAddress*>* pois, NSError* err ))callback;
/**
 *  @brief Cancel a processing request.
 *
 *  @param request The id of request.
 */
- (void)cancelRequest:(id)request;

@end
