//
//  UCarMapSearchService.m
//  UCar
//
//  Created by huangyi on 5/31/16.
//  Copyright © 2016 huangyi. All rights reserved.
//

#import "UCarMapSearchService.h"
#import "UCarMapSearchInternal.h"
#import "UCarMapSearchImpl.h"
#import "UCarMapSearchImplFactory.h"

typedef void (^UCarMapSearchRequestCallback)( id result, NSError* err );

typedef enum UCarMapSearchRequestType
{
    UCarMapSearchRequestType_POI
    , UCarMapSearchRequestType_Route
    , UCarMapSearchRequestType_Geocode
    , UCarMapSearchRequestType_RGeocode
    , UCarMapSearchRequestType_Keyword
    , UCarMapSearchRequestType_Walking
    , UCarMapSearchRequestType_Transit
} UCarMapSearchRequestType;

@interface UCarMapSearchRequest : NSObject
@property (nonatomic, strong) UCarMapSearchRequestCallback      callback;
@property (nonatomic, assign) UCarMapSearchRequestType          type;
@property (nonatomic, strong) id                                request;
@end

@implementation UCarMapSearchRequest
@synthesize callback;
@synthesize type;
@end

@interface UCarMapSearchService() <UCarMapSearchImplDelegate>
{
    id<UCarMapSearchImpl>   impl;
    NSMutableArray*         searchRequestQueue;
    UCarMapSearchRequest*   currentRequest;
    UCarMapImplementType    currentImplementType;
}

- (void)updateImplement;
- (void)processRequest;
- (void)clearRequest;
@end

@implementation UCarMapSearchService

@synthesize implementType;

- (void)setImplementType:(UCarMapImplementType)type
{
    [UCarMapType setMapType:type];
    if ( implementType != type )
    {
        implementType = type;
        if ( impl )
        {
            if ( !currentRequest )
            {
                [self updateImplement];
            }
        }
        else
        {
            [self updateImplement];
            [self processRequest];
        }
    }
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static UCarMapSearchService* instance = nil;
    dispatch_once( &onceToken, ^{
        instance = [[UCarMapSearchService alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        searchRequestQueue = [[NSMutableArray alloc] init];
        currentRequest = nil;
        currentImplementType = UCarMapImplementType_None;
        implementType = UCarMapImplementType_None;
    }
    return self;
}

- (void)dealloc
{
    [self clearRequest];
}

- (__weak id)searchDrivingRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination complete:(void(^)( UCarMapPath* path, NSError* err ))callback
{
    return [self searchDrivingRouteFrom:origin to:destination withStrategy:UCarMapSearchRouteStrategy_Fastest complete:callback];
}

- (__weak id)searchDrivingRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination withStrategy:(UCarMapSearchRouteStrategy)strategy complete:(void(^)( UCarMapPath* path, NSError* err ))callback
{
    return [self searchDrivingRouteFrom:origin to:destination wayPoints:nil withStrategy:strategy complete:callback];
}

- (__weak id)searchDrivingRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination wayPoints:(NSArray*)wayPoints withStrategy:(UCarMapSearchRouteStrategy)strategy complete:(void(^)( UCarMapPath* path, NSError* err ))callback
{
    UCarMapSearchRequest* request = [[UCarMapSearchRequest alloc] init];
    request.callback = callback;
    request.type = UCarMapSearchRequestType_Route;
    UCarMapSearchRouteRequest* routeRequest = [[UCarMapSearchRouteRequest alloc] init];
    routeRequest.origin = origin;
    routeRequest.destination = destination;
    routeRequest.wayPoints = [NSArray arrayWithArray:wayPoints];
    routeRequest.strategy = strategy;
    request.request = routeRequest;
    [searchRequestQueue addObject:request];
    [self processRequest];
    return request;
}

- (__weak id)searchWalkingRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination complete:(void(^)( UCarMapPath* path, NSError* err ))callback
{
    UCarMapSearchRequest* request = [[UCarMapSearchRequest alloc] init];
    request.callback = callback;
    request.type = UCarMapSearchRequestType_Walking;
    UCarMapSearchWalkingRouteRequest* routeRequest = [[UCarMapSearchWalkingRouteRequest alloc] init];
    routeRequest.origin = origin;
    routeRequest.destination = destination;
    request.request = routeRequest;
    [searchRequestQueue addObject:request];
    [self processRequest];
    return request;
}

- (__weak id)searchTransitRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination city:(NSString *)city nightFlag:(BOOL)nightFlag complete:(void(^)( NSArray<UCarMapTransit*>* transits, NSError* err ))callback
{
    return [self searchTransitRouteFrom:origin to:destination city:city DestinationCity:nil  nightFlag:nightFlag complete:callback];
}

- (__weak id)searchTransitRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination city:(NSString *)city DestinationCity:(NSString *)destCity nightFlag:(BOOL)nightFlag complete:(void(^)( NSArray<UCarMapTransit*>* transits, NSError* err ))callback
{
    UCarMapSearchRequest* request = [[UCarMapSearchRequest alloc] init];
    request.callback = callback;
    request.type = UCarMapSearchRequestType_Transit;
    UCarMapSearchTransitRouteRequest* routeRequest = [[UCarMapSearchTransitRouteRequest alloc] init];
    routeRequest.origin = origin;
    routeRequest.destination = destination;
    routeRequest.city = city;
    routeRequest.destCity = destCity;
    routeRequest.nightFlag = nightFlag;
    request.request = routeRequest;
    [searchRequestQueue addObject:request];
    [self processRequest];
    return request;
}

- (__weak id)searchGeoCode:(NSString*)cityName address:(NSString*)addressName complete:(void(^)( NSArray<UCarMapAddress*>* address, NSError* err ))callback
{
    UCarMapSearchRequest* request = [[UCarMapSearchRequest alloc] init];
    request.callback = callback;
    request.type = UCarMapSearchRequestType_Geocode;
    
    UCarMapSearchGeocodeRequest* geocodeRequest = [[UCarMapSearchGeocodeRequest alloc] init];
    geocodeRequest.city = cityName;
    geocodeRequest.address = addressName;
    request.request = geocodeRequest;
    [searchRequestQueue addObject:request];
    [self processRequest];
    return request;
}

- (__weak id)reverseGeoCode:(UCarMapCoordinate*)coordinate complete:(void(^)( NSArray<UCarMapAddress*>* address, NSError* err ))callback
{
    UCarMapSearchRequest* request = [[UCarMapSearchRequest alloc] init];
    request.callback = callback;
    request.type = UCarMapSearchRequestType_RGeocode;
    UCarMapSearchRGeocodeRequest* rgeocodeRequest = [[UCarMapSearchRGeocodeRequest alloc] init];
    rgeocodeRequest.coordinate = coordinate;
    request.request = rgeocodeRequest;
    [searchRequestQueue addObject:request];
    [self processRequest];
    return request;
}

- (__weak id)searchPOI:(UCarMapCoordinate*)coordinate complete:(void(^)( NSArray<UCarMapAddress*>* pois, NSError* err ))callback
{
    return [self searchPOI:coordinate poiTypes:0 complete:callback];
}

- (__weak id)searchPOI:(UCarMapCoordinate*)coordinate poiTypes:(NSInteger)poiTypes complete:(void(^)( NSArray<UCarMapAddress*>* pois, NSError* err ))callback
{
    return [self searchPOI:coordinate poiTypes:poiTypes distance:5000 pageCount:30 complete:callback];
}

- (__weak id)searchPOI:(UCarMapCoordinate*)coordinate poiTypes:(NSInteger)poiTypes distance:(CGFloat)distance pageCount:(NSInteger)count complete:(void(^)( NSArray<UCarMapAddress*>* pois, NSError* err ))callback
{
    UCarMapSearchRequest* request = [[UCarMapSearchRequest alloc] init];
    request.callback = callback;
    request.type = UCarMapSearchRequestType_POI;
    UCarMapSearchPOIRequest* poiRequest = [[UCarMapSearchPOIRequest alloc] init];
    poiRequest.coordinate = coordinate;
    poiRequest.poiTypes = poiTypes;
    poiRequest.distance = distance;
    poiRequest.pageCount = count;
    request.request = poiRequest;
    [searchRequestQueue addObject:request];
    [self processRequest];
    return request;
}

- (__weak id)searchKeyword:(NSString* )keyword cityName:(NSString * )cityname poiType:(NSInteger)types complete:(void(^)( NSArray<UCarMapAddress*>* pois, NSError* err ))callback
{
    UCarMapSearchRequest* request = [[UCarMapSearchRequest alloc] init];
    request.callback = callback;
    request.type = UCarMapSearchRequestType_Keyword;
    UCarMapSearchKeywordRequest* poiRequest = [[UCarMapSearchKeywordRequest alloc] init];
    poiRequest.keyword = keyword;
    poiRequest.city = cityname;
    poiRequest.poiTypes = types;
    request.request = poiRequest;
    [searchRequestQueue addObject:request];
    [self processRequest];
    return request;
}

- (void)cancelRequest:(id)ID
{
    if ( ID == currentRequest )
    {
        currentRequest.callback = nil;
    }
    else
    {
        NSUInteger index = [searchRequestQueue indexOfObject:ID];
        if ( index != NSNotFound )
        {
            [searchRequestQueue removeObjectAtIndex:index];
        }
    }
}

#pragma mark - UCarMapSearchImplDelegate
- (void)searchDrivingRouteComplete:(UCarMapPath*)path error:(NSError*)err
{
    if ( currentRequest && currentRequest.type == UCarMapSearchRequestType_Route )
    {
        if ( currentRequest.callback )
        {
            currentRequest.callback( path, err );
        }
        if ( err )
        {
            //[UCARClientMonitor exception:@"amp_rute_error"  extra:@{MONITOR_CODE_PAGE_NAME:NSStringFromClass([self class])}];
        }
        currentRequest = nil;
    }
    [self processRequest];
}

- (void)searchWalkingRouteComplete:(UCarMapPath*)path error:(NSError*)err
{
    if ( currentRequest && currentRequest.type == UCarMapSearchRequestType_Walking )
    {
        if ( currentRequest.callback )
        {
            currentRequest.callback( path, err );
        }
        if ( err )
        {
            //[UCARClientMonitor exception:@"amp_rute_error"  extra:@{MONITOR_CODE_PAGE_NAME:NSStringFromClass([self class])}];
        }
        currentRequest = nil;
    }
    [self processRequest];
}

- (void)searchTransitRouteComplete:(NSArray<UCarMapTransit*>*)transits error:(NSError*)err;
{
    if ( currentRequest && currentRequest.type == UCarMapSearchRequestType_Transit )
    {
        if ( currentRequest.callback )
        {
            currentRequest.callback( transits, err );
        }
        if ( err )
        {
            //[UCARClientMonitor exception:@"amp_rute_error"  extra:@{MONITOR_CODE_PAGE_NAME:NSStringFromClass([self class])}];
        }
        currentRequest = nil;
    }
    [self processRequest];
}

- (void)searchPOIComplete:(NSArray<UCarMapAddress *> *)result error:(NSError *)err
{
    if ( currentRequest && currentRequest.type == UCarMapSearchRequestType_POI )
    {
        if ( currentRequest.callback )
        {
            currentRequest.callback( result, err );
        }
        if ( err )
        {
            //[UCARClientMonitor exception:@"amp_poi_error"  extra:@{MONITOR_CODE_PAGE_NAME:NSStringFromClass([self class])}];
        }
        currentRequest = nil;
    }
    [self processRequest];
}

- (void)searchGeocodeComplete:(NSArray<UCarMapAddress *> *)result error:(NSError *)err
{
    if ( currentRequest && currentRequest.type == UCarMapSearchRequestType_Geocode )
    {
        if ( currentRequest.callback )
        {
            currentRequest.callback( result, err );
        }
        if ( err )
        {
            //[UCARClientMonitor exception:@"amp_geo_error"  extra:@{MONITOR_CODE_PAGE_NAME:NSStringFromClass([self class])}];
        }
        currentRequest = nil;
    }
    [self processRequest];
}

- (void)searchReverseGeocodeComplete:(NSArray<UCarMapAddress *> *)result error:(NSError *)err
{
    if ( currentRequest && currentRequest.type == UCarMapSearchRequestType_RGeocode )
    {
        if ( currentRequest.callback )
        {
            currentRequest.callback( result, err );
        }
        if ( err )
        {
            //[UCARClientMonitor exception:@"amp_rgeo_error"  extra:@{MONITOR_CODE_PAGE_NAME:NSStringFromClass([self class])}];
        }
        currentRequest = nil;
    }
    [self processRequest];
}

- (void)searchKeywordComplete:(NSArray<UCarMapAddress*>*)result error:(NSError *)err
{
    if ( currentRequest && currentRequest.type == UCarMapSearchRequestType_Keyword )
    {
        if ( currentRequest.callback )
        {
            currentRequest.callback( result, err );
        }
        if ( err )
        {
            //[UCARClientMonitor exception:@"amp_keyword_error"  extra:@{MONITOR_CODE_PAGE_NAME:NSStringFromClass([self class])}];
        }
        currentRequest = nil;
    }
    [self processRequest];
}

#pragma mark - Private

- (void)updateImplement
{
    if ( currentImplementType != implementType )
    {
        currentImplementType = implementType;
        if ( impl )
        {
            impl.delegate = nil;
            impl = nil;
        }
        impl = [UCarMapSearchImplFactory GetMapImpl:implementType];
        if ( impl )
        {
            impl.delegate = self;
        }
    }
}

- (void)processRequest
{
    if ( impl && nil == currentRequest && searchRequestQueue.count > 0)
    {
        [self updateImplement];
        currentRequest = searchRequestQueue[0];
        [searchRequestQueue removeObjectAtIndex:0];
        switch ( currentRequest.type )
        {
            case UCarMapSearchRequestType_POI:
                {
                    UCarMapSearchPOIRequest* poiRequest = currentRequest.request;
                    [impl searchPOI:poiRequest.coordinate poiTypes:poiRequest.poiTypes distance:poiRequest.distance pageCount:poiRequest.pageCount];
                }
                break;
            case UCarMapSearchRequestType_Route:
                {
                    UCarMapSearchRouteRequest* routeRequest = currentRequest.request;
                    [impl searchDrivingRouteFrom:routeRequest.origin to:routeRequest.destination wayPoints:routeRequest.wayPoints withStrategy:routeRequest.strategy];
                }
                break;
            case UCarMapSearchRequestType_Geocode:
                {
                    UCarMapSearchGeocodeRequest* geocodeRequest = currentRequest.request;
                    [impl searchGeoCode:geocodeRequest.city address:geocodeRequest.address];
                }
                break;
            case UCarMapSearchRequestType_RGeocode:
                {
                    UCarMapSearchRGeocodeRequest* rgeocodeRequest = currentRequest.request;
                    [impl searchReverseGeoCode:rgeocodeRequest.coordinate];
                }
                break;
            case UCarMapSearchRequestType_Keyword:
                {
                    UCarMapSearchKeywordRequest* keywordRequest = currentRequest.request;
                    [impl searchKeyword:keywordRequest.keyword cityName:keywordRequest.city poiTypes:keywordRequest.poiTypes];
                }
                break;
            case UCarMapSearchRequestType_Walking:
            {
                UCarMapSearchWalkingRouteRequest* routeRequest = currentRequest.request;
                [impl searchWalkingRouteFrom:routeRequest.origin to:routeRequest.destination];
            }
                break;
            case UCarMapSearchRequestType_Transit:
            {
                UCarMapSearchTransitRouteRequest* routeRequest = currentRequest.request;
                [impl searchTransitRouteFrom:routeRequest.origin to:routeRequest.destination city:routeRequest.city  DestinationCity:routeRequest.destCity nightFlag:routeRequest.nightFlag];
            }
                break;
            default:
                break;
        }
    }
}

- (void)clearRequest
{
    NSError* err = [NSError errorWithDomain:@"UCarMapSearch" code:UCarMapSearchServerceError_Canceled userInfo:nil];
    if ( currentRequest )
    {
        currentRequest.callback( nil, err );
        currentRequest = nil;
    }
    for ( UCarMapSearchRequest* request in searchRequestQueue )
    {
        request.callback( nil, err );
    }
    [searchRequestQueue removeAllObjects];
}

@end
