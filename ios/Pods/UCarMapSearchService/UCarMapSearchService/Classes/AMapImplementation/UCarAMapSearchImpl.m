//
//  UCarAMapSearchImpl.m
//  UCar
//
//  Created by huangyi on 9/1/16.
//  Copyright © 2016 huangyi. All rights reserved.
//

#import "UCarAMapSearchImpl.h"
#import "UCarMapSearchInternal.h"
#import <AMapSearchKit/AMapSearchKit.h>
//#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface UCarAMapSearchImpl() <AMapSearchDelegate>
{
    AMapSearchAPI*              searchAPI;
}

- (UCarMapPath*)convertAMapPath:(AMapPath*)path;
- (UCarMapAddress*)convertAMapPOI:(AMapPOI*)poi;
- (UCarMapAddress*)convertAMapAddress:(AMapAddressComponent*)address;

- (NSString*)convertPOITypes:(NSInteger)poiTypes;
@end

@implementation UCarAMapSearchImpl

@synthesize delegate;

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        [[AMapServices sharedServices] setEnableHTTPS:YES];
        [AMapServices sharedServices].apiKey = [UCarMapFundation sharedInstance].keys[AMAP_KEY];
        searchAPI = [[AMapSearchAPI alloc] init];
        searchAPI.delegate = self;
    }
    return self;
}

- (void)searchDrivingRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination wayPoints:(NSArray*)wayPoints withStrategy:(UCarMapSearchRouteStrategy)strategy
{
    AMapDrivingRouteSearchRequest* amapSearchRequest = [[AMapDrivingRouteSearchRequest alloc] init];
    amapSearchRequest.requireExtension = YES;
    switch (strategy)
    {
        case UCarMapSearchRouteStrategy_Fastest:
            amapSearchRequest.strategy = 0;
            break;
        case UCarMapSearchRouteStrategy_Shortest:
            amapSearchRequest.strategy = 2;
            break;
        case UCarMapSearchRouteStrategy_AvoidTrafficJam:
            amapSearchRequest.strategy = 4;
            break;
        default:
            amapSearchRequest.strategy = 2;
            break;
    }
    amapSearchRequest.origin = [AMapGeoPoint locationWithLatitude:origin.amapCoordinate.latitude longitude:origin.amapCoordinate.longitude];
    amapSearchRequest.destination = [AMapGeoPoint locationWithLatitude:destination.amapCoordinate.latitude longitude:destination.amapCoordinate.longitude];
    if ( wayPoints )
    {
        NSMutableArray* amapWaypoints = [[NSMutableArray alloc] init];
        for ( UCarMapCoordinate* wayPoint in wayPoints )
        {
            AMapGeoPoint* node = [AMapGeoPoint locationWithLatitude:wayPoint.amapCoordinate.latitude longitude:wayPoint.amapCoordinate.longitude];
            [amapWaypoints addObject:node];
        }
        amapSearchRequest.waypoints = amapWaypoints;
    }
    [searchAPI AMapDrivingRouteSearch:amapSearchRequest];
}

- (void)searchGeoCode:(NSString*)city address:(NSString*)address
{
    AMapGeocodeSearchRequest *geoRequest = [[AMapGeocodeSearchRequest alloc] init];
    geoRequest.city = city;
    geoRequest.address = address;
    // 发起正向地理编码
    [searchAPI AMapGeocodeSearch:geoRequest];
}

- (void)searchReverseGeoCode:(UCarMapCoordinate*)coordinate
{
    AMapReGeocodeSearchRequest* amapSearchRequest = [[AMapReGeocodeSearchRequest alloc] init];
    amapSearchRequest.requireExtension = YES;
    amapSearchRequest.location = [AMapGeoPoint locationWithLatitude:coordinate.amapCoordinate.latitude longitude:coordinate.amapCoordinate.longitude];
    [searchAPI AMapReGoecodeSearch:amapSearchRequest];
}

- (void)searchPOI:(UCarMapCoordinate*)coordinate poiTypes:(NSInteger)poiTypes distance:(CGFloat)distance pageCount:(NSInteger)count
{
    AMapPOIAroundSearchRequest *amapSearchRequest = [[AMapPOIAroundSearchRequest alloc] init];
    amapSearchRequest.location = [AMapGeoPoint locationWithLatitude:coordinate.amapCoordinate.latitude longitude:coordinate.amapCoordinate.longitude];
    amapSearchRequest.requireExtension = YES;
    amapSearchRequest.sortrule = 1;
    amapSearchRequest.radius = distance;
    amapSearchRequest.offset = count;
    if ( poiTypes )
    {
        amapSearchRequest.types = [self convertPOITypes:poiTypes];
    }
    [searchAPI AMapPOIAroundSearch:amapSearchRequest];
}

- (void)searchKeyword:(NSString*)keyword cityName:(NSString*)city poiTypes:(NSInteger)poiTypes
{
    AMapPOIKeywordsSearchRequest* keywordRequest = [[AMapPOIKeywordsSearchRequest alloc] init];
    keywordRequest.requireExtension = YES;
    keywordRequest.keywords = keyword;
    keywordRequest.city = city;
    keywordRequest.cityLimit = YES;
    keywordRequest.sortrule = 1;
    if ( poiTypes )
    {
        keywordRequest.types = [self convertPOITypes:poiTypes];
    }
    [searchAPI AMapPOIKeywordsSearch:keywordRequest];
}

- (void)searchWalkingRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination
{
    AMapWalkingRouteSearchRequest* amapSearchRequest = [[AMapWalkingRouteSearchRequest alloc] init];
    amapSearchRequest.origin = [AMapGeoPoint locationWithLatitude:origin.amapCoordinate.latitude longitude:origin.amapCoordinate.longitude];
    amapSearchRequest.destination = [AMapGeoPoint locationWithLatitude:destination.amapCoordinate.latitude longitude:destination.amapCoordinate.longitude];
    [searchAPI AMapWalkingRouteSearch:amapSearchRequest];
}

- (void)searchTransitRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination city:(NSString *)city nightFlag:(BOOL)nightFlag
{
    [self searchTransitRouteFrom:origin to:destination city:city DestinationCity:nil nightFlag:nightFlag];
}

- (void)searchTransitRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination city:(NSString *)city DestinationCity:(NSString *)destCity nightFlag:(BOOL)nightFlag
{
    AMapTransitRouteSearchRequest *amapSearchRequest = [[AMapTransitRouteSearchRequest alloc] init];
    amapSearchRequest.requireExtension = YES;
    amapSearchRequest.city = city;
    if(destCity != nil)
    {
        amapSearchRequest.destinationCity = city;
    }
    amapSearchRequest.nightflag = nightFlag;
    amapSearchRequest.origin = [AMapGeoPoint locationWithLatitude:origin.amapCoordinate.latitude longitude:origin.amapCoordinate.longitude];
    amapSearchRequest.destination = [AMapGeoPoint locationWithLatitude:destination.amapCoordinate.latitude longitude:destination.amapCoordinate.longitude];
    
    [searchAPI AMapTransitRouteSearch:amapSearchRequest];
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    if ( [request isKindOfClass:[AMapDrivingRouteSearchRequest class]] )
    {
        if ( delegate && [delegate respondsToSelector:@selector(searchDrivingRouteComplete:error:)] )
        {
            AMapRouteSearchBaseRequest* routeRequest = (AMapRouteSearchBaseRequest*)request;
            UCarMapPath* path = [[UCarMapPath alloc] init];
            CLLocation *point1 = [[CLLocation alloc] initWithLatitude:routeRequest.origin.latitude longitude:routeRequest.origin.longitude];
            CLLocation *point2 = [[CLLocation alloc] initWithLatitude:routeRequest.destination.latitude longitude:routeRequest.destination.longitude];
            path.distance = [point1 distanceFromLocation:point2];
            path.duration = path.distance * 0.18f;
            [delegate searchDrivingRouteComplete:path error:error];
        }
    }
    
    if ( [request isKindOfClass:[AMapWalkingRouteSearchRequest class]] )
    {
        if ( delegate && [delegate respondsToSelector:@selector(searchWalkingRouteComplete:error:)] )
        {
            AMapWalkingRouteSearchRequest* routeRequest = (AMapWalkingRouteSearchRequest*)request;
            UCarMapPath* path = [[UCarMapPath alloc] init];
            CLLocation *point1 = [[CLLocation alloc] initWithLatitude:routeRequest.origin.latitude longitude:routeRequest.origin.longitude];
            CLLocation *point2 = [[CLLocation alloc] initWithLatitude:routeRequest.destination.latitude longitude:routeRequest.destination.longitude];
            path.distance = [point1 distanceFromLocation:point2];
            path.duration = path.distance * 0.18f;
            [delegate searchWalkingRouteComplete:path error:error];
        }
    }
    
    if ( [request isKindOfClass:[AMapTransitRouteSearchRequest class]] )
    {
        if ( delegate && [delegate respondsToSelector:@selector(searchTransitRouteComplete:error:)] )
        {
            [delegate searchTransitRouteComplete:nil error:error];
        }
    }
    
    if ( [request isKindOfClass:[AMapGeocodeSearchRequest class]] )
    {
        if ( delegate && [delegate respondsToSelector:@selector(searchGeocodeComplete:error:)] )
        {
            [delegate searchGeocodeComplete:nil error:error];
        }
    }

    if ( [request isKindOfClass:[AMapReGeocodeSearchRequest class]] )
    {
        if ( delegate && [delegate respondsToSelector:@selector(searchReverseGeocodeComplete:error:)] )
        {
            [delegate searchReverseGeocodeComplete:nil error:error];
        }
    }
    if ( [request isKindOfClass:[AMapPOIAroundSearchRequest class]] )
    {
        if ( delegate && [delegate respondsToSelector:@selector(searchPOIComplete:error:)] )
        {
            [delegate searchPOIComplete:nil error:error];
        }
    }
    if ( [request isKindOfClass:[AMapPOIKeywordsSearchRequest class]] )
    {
        if ( delegate && [delegate respondsToSelector:@selector(searchKeywordComplete:error:)] )
        {
            [delegate searchKeywordComplete:nil error:error];
        }
    }
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if ( [request isKindOfClass:[AMapPOIKeywordsSearchRequest class]] )
    {
        if ( delegate && [delegate respondsToSelector:@selector(searchKeywordComplete:error:)] )
        {
            NSMutableArray* result = [[NSMutableArray alloc] init];
            for ( AMapPOI* poi in response.pois )
            {
                [result addObject:[self convertAMapPOI:poi]];
            }
            [delegate searchKeywordComplete:result error:nil];
        }
    }
    else if ( [request isKindOfClass:[AMapPOIAroundSearchRequest class]] )
    {
        if ( delegate && [delegate respondsToSelector:@selector(searchPOIComplete:error:)] )
        {
            NSMutableArray* result = [[NSMutableArray alloc] init];
            for ( AMapPOI* poi in response.pois )
            {
                [result addObject:[self convertAMapPOI:poi]];
            }
            [delegate searchPOIComplete:result error:nil];
        }
    }
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if ( delegate && [delegate respondsToSelector:@selector(searchGeocodeComplete:error:)] )
    {
        NSMutableArray* result = [[NSMutableArray alloc] init];
        
        for ( AMapGeocode* gecode in response.geocodes )
        {
            UCarMapAddress* address = [UCarMapAddress new];
            address.formattedAddress = gecode.formattedAddress;
            address.addressDetail = gecode.formattedAddress;
            UCarMapCoordinate* coordinate = [[UCarMapCoordinate alloc] init];
            coordinate.amapCoordinate = CLLocationCoordinate2DMake( gecode.location.latitude, gecode.location.longitude );
            address.coordinate = coordinate;
            address.addressDetail = gecode.formattedAddress;
            [result addObject:address];
        }
        [delegate searchGeocodeComplete:result error:nil];
    }
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if ( delegate && [delegate respondsToSelector:@selector(searchReverseGeocodeComplete:error:)] )
    {
        NSMutableArray* result = [[NSMutableArray alloc] init];
        UCarMapAddress* address = [self convertAMapAddress:response.regeocode.addressComponent];
        address.formattedAddress = response.regeocode.formattedAddress;
        address.coordinate.amapCoordinate = CLLocationCoordinate2DMake( request.location.latitude, request.location.longitude );
        address.addressDetail = response.regeocode.formattedAddress;
        [result addObject:address];
        for ( AMapPOI* poi in response.regeocode.pois )
        {
            [result addObject:[self convertAMapPOI:poi]];
        }
        [delegate searchReverseGeocodeComplete:result error:nil];
    }
}

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    
}

- (void)onBusStopSearchDone:(AMapBusStopSearchRequest *)request response:(AMapBusStopSearchResponse *)response
{
    
}

- (void)onBusLineSearchDone:(AMapBusLineBaseSearchRequest *)request response:(AMapBusLineSearchResponse *)response
{
    
}

- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response
{
    
}

- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    AMapRouteSearchBaseRequest* routeRequest = (AMapRouteSearchBaseRequest*)request;
    if ( [request isKindOfClass:[AMapTransitRouteSearchRequest class]] )
    {
        if ( !response.route || response.route.transits.count == 0)
        {
            if ( delegate && [delegate respondsToSelector:@selector(searchTransitRouteComplete:error:)] )
            {
                [delegate searchTransitRouteComplete:nil error:[NSError errorWithDomain:@"UCarMapSearch" code:UCarMapSearchServerceError_NoResult userInfo:nil]];
            }
        }
        else
        {
            if ( delegate && [delegate respondsToSelector:@selector(searchTransitRouteComplete:error:)] )
            {
                [delegate searchTransitRouteComplete:[self convertAMapTransit:response.route.transits] error:nil];
            }
        }
    }
    else
    {
        if ( !response.route || response.route.paths.count == 0 )
        {
            UCarMapPath* path = [[UCarMapPath alloc] init];
            CLLocation *point1 = [[CLLocation alloc] initWithLatitude:routeRequest.origin.latitude longitude:routeRequest.origin.longitude];
            CLLocation *point2 = [[CLLocation alloc] initWithLatitude:routeRequest.destination.latitude longitude:routeRequest.destination.longitude];
            path.distance = [point1 distanceFromLocation:point2];
            path.duration = path.distance * 0.18f;
            
            if ([request isKindOfClass:[AMapDrivingRouteSearchRequest class]])
            {
                if ( delegate && [delegate respondsToSelector:@selector(searchDrivingRouteComplete:error:)] )
                {
                    [delegate searchDrivingRouteComplete:path error:[NSError errorWithDomain:@"UCarMapSearch" code:UCarMapSearchServerceError_NoResult userInfo:nil]];
                }
            }
            
            if ( [request isKindOfClass:[AMapWalkingRouteSearchRequest class]] )
            {
                if ( delegate && [delegate respondsToSelector:@selector(searchWalkingRouteComplete:error:)] )
                {
                    [delegate searchWalkingRouteComplete:path error:[NSError errorWithDomain:@"UCarMapSearch" code:UCarMapSearchServerceError_NoResult userInfo:nil]];
                }
            }
        }
        else
        {
            if ([request isKindOfClass:[AMapDrivingRouteSearchRequest class]])
            {
                if ( delegate && [delegate respondsToSelector:@selector(searchDrivingRouteComplete:error:)] )
                {
                    [delegate searchDrivingRouteComplete:[self convertAMapPath:response.route.paths[0]] error:nil];
                }
            }
            
            if ([request isKindOfClass:[AMapWalkingRouteSearchRequest class]])
            {
                if ( delegate && [delegate respondsToSelector:@selector(searchWalkingRouteComplete:error:)] )
                {
                    [delegate searchWalkingRouteComplete:[self convertAMapPath:response.route.paths[0]] error:nil];
                }
            }
        }
    }
}

- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{
    
}

#pragma mark - Private
- (UCarMapPath*)convertWalkingPath:(AMapWalking*)amapWalking
{
    NSMutableArray* steps = [[NSMutableArray alloc] init];
    UCarMapCoordinate* lastCoordinate = nil;
    for ( AMapStep* amapStep in amapWalking.steps )
    {
        NSMutableArray* coordinates = [[NSMutableArray alloc] init];
        NSString* str = [amapStep.polyline stringByReplacingOccurrencesOfString:@";" withString:@","];
        NSArray *components = [str componentsSeparatedByString:@","];
        NSUInteger count = [components count] / 2;
        if ( lastCoordinate )
        {
            [coordinates addObject:lastCoordinate];
        }
        for ( NSInteger i = 0; i < count; ++i )
        {
            UCarMapCoordinate* coordinate = [[UCarMapCoordinate alloc] init];
            coordinate.amapCoordinate = CLLocationCoordinate2DMake( [[components objectAtIndex:2 * i + 1] doubleValue], [[components objectAtIndex:2 * i] doubleValue]);
            [coordinates addObject:coordinate];
            lastCoordinate = coordinate;
        }
        UCarMapPathStep* step = [[UCarMapPathStep alloc] init];
        step.coordinates = coordinates;
        step.distance = amapStep.distance;
        step.road = amapStep.road;
        step.instruction = amapStep.instruction;
        [steps addObject:step];
    }
    UCarMapPath* path = [[UCarMapPath alloc] init];
    path.steps = steps;
    path.distance = amapWalking.distance;
    path.duration = amapWalking.duration;
    return path;
}

- (NSArray<UCarMapTransit*>*)convertAMapTransit:(NSArray<AMapTransit*>*)amapTransits
{
    NSMutableArray* transits = [[NSMutableArray alloc] init];
    for (AMapTransit* amapTransit in amapTransits) {
        NSMutableArray* segments = [[NSMutableArray alloc] init];
        for ( AMapSegment* amapSegment in amapTransit.segments )
        {
            NSMutableArray* buslines = [[NSMutableArray alloc] init];
            UCarMapCoordinate* lastCoordinate = nil;
            for ( AMapBusLine* amapBusline in amapSegment.buslines )
            {
                NSMutableArray* coordinates = [[NSMutableArray alloc] init];
                NSString* str = [amapBusline.polyline stringByReplacingOccurrencesOfString:@";" withString:@","];
                NSArray *components = [str componentsSeparatedByString:@","];
                NSUInteger count = [components count] / 2;
                if ( lastCoordinate )
                {
                    [coordinates addObject:lastCoordinate];
                }
                for ( NSInteger i = 0; i < count; ++i )
                {
                    UCarMapCoordinate* coordinate = [[UCarMapCoordinate alloc] init];
                    coordinate.amapCoordinate = CLLocationCoordinate2DMake( [[components objectAtIndex:2 * i + 1] doubleValue], [[components objectAtIndex:2 * i] doubleValue]);
                    [coordinates addObject:coordinate];
                    lastCoordinate = coordinate;
                }
                
                UCarMapBusline* busline = [[UCarMapBusline alloc] init];
                busline.coordinates = coordinates;
                busline.type = amapBusline.type;
                busline.name = amapBusline.name;
                busline.distance = amapBusline.distance;
                busline.busStopCount = amapBusline.busStops.count;
                busline.departureStopName = amapBusline.departureStop.name;
                busline.arrivalStopName = amapBusline.arrivalStop.name;
                
                [buslines addObject:busline];
            }
            
            UCarMapSegment* segment = [[UCarMapSegment alloc] init];
            segment.walking = [self convertWalkingPath:amapSegment.walking];
            segment.buslines = buslines;
            [segments addObject:segment];
        }
        UCarMapTransit* transit = [[UCarMapTransit alloc] init];
        transit.segments = segments;
        transit.distance = amapTransit.distance;
        transit.duration = amapTransit.duration;
        transit.walkingDistance = amapTransit.walkingDistance;
        
        [transits addObject:transit];
    }
    
    return transits;
}

- (UCarMapPath*)convertAMapPath:(AMapPath*)amapPath;
{
    NSMutableArray* steps = [[NSMutableArray alloc] init];
    UCarMapCoordinate* lastCoordinate = nil;
    for ( AMapStep* amapStep in amapPath.steps )
    {
        NSMutableArray* coordinates = [[NSMutableArray alloc] init];
        NSString* str = [amapStep.polyline stringByReplacingOccurrencesOfString:@";" withString:@","];
        NSArray *components = [str componentsSeparatedByString:@","];
        NSUInteger count = [components count] / 2;
        if ( lastCoordinate )
        {
            [coordinates addObject:lastCoordinate];
        }
        for ( NSInteger i = 0; i < count; ++i )
        {
            UCarMapCoordinate* coordinate = [[UCarMapCoordinate alloc] init];
            coordinate.amapCoordinate = CLLocationCoordinate2DMake( [[components objectAtIndex:2 * i + 1] doubleValue], [[components objectAtIndex:2 * i] doubleValue]);
            [coordinates addObject:coordinate];
            lastCoordinate = coordinate;
        }
        UCarMapPathStep* step = [[UCarMapPathStep alloc] init];
        step.coordinates = coordinates;
        step.distance = amapStep.distance;
        step.road = amapStep.road;
        step.instruction = amapStep.instruction;
        [steps addObject:step];
    }
    UCarMapPath* path = [[UCarMapPath alloc] init];
    path.steps = steps;
    path.distance = amapPath.distance;
    path.duration = amapPath.duration;
    return path;
}

- (UCarMapAddress*)convertAMapPOI:(AMapPOI*)poi
{
    UCarMapAddress* addr = [[UCarMapAddress alloc] init];
    if(!poi.city || [poi.city isEqualToString:@""])
    {
        addr.cityName = poi.province;
    }
    else
    {
        addr.cityName = poi.city;
    }

    addr.addressName = poi.name;
    if ( poi.address && poi.address.length > 0 )
    {
        addr.addressDetail = poi.address;
    }
    else
    {
        addr.addressDetail = poi.name;
    }
    addr.coordinate = [[UCarMapCoordinate alloc] init];
    addr.coordinate.amapCoordinate = CLLocationCoordinate2DMake( poi.location.latitude, poi.location.longitude );
    addr.district = poi.district;
    addr.citycode = poi.citycode;
    addr.uid = poi.uid;
    addr.type = poi.type;
    addr.distance = poi.distance;
    
    return addr;
}

- (UCarMapAddress*)convertAMapAddress:(AMapAddressComponent*)address
{
    UCarMapAddress* addr = [[UCarMapAddress alloc] init];
    if(!address.city || [address.city isEqualToString:@""])
    {
        addr.cityName = address.province;
    }
    else
    {
        addr.cityName = address.city;
    }

    if ( address.building && address.building.length > 0 )
    {
        addr.addressName = address.building;
        addr.addressDetail = address.building;
    }
    else
    {
        addr.addressName = address.streetNumber.street;
        addr.addressDetail = address.streetNumber.street;
    }
    addr.coordinate = [[UCarMapCoordinate alloc] init];
    addr.district = address.district;
    if ( address.province.length > 0 )
    {
        addr.province = address.province;
    }
    if ( address.streetNumber )
    {
        if ( address.streetNumber.street.length > 0 )
        {
            addr.street = address.streetNumber.street;
        }
        if ( address.streetNumber.number.length > 0 )
        {
            addr.number = address.streetNumber.number;
        }
    }
    if ( address.citycode.length > 0 )
    {
        addr.uniqueID = address.citycode;
    }
    else
    {
        addr.uniqueID = @"";
    }
    return addr;
}

- (NSString*)convertPOITypes:(NSInteger)poiTypes
{
    if ( poiTypes == UCarMapSearchPOIType_All )
    {
        return @"商场|超级市场|邮局|运动场馆|高尔夫相关|影剧院|综合医院|专科医院|急救中心|宾馆酒店|公园广场|公园|动物园|植物园|水族馆|城市广场|世界遗产|国家级景点|省级景点|纪念馆|寺庙道观|教堂|回教寺|海滩|观景点|产业园区|楼宇|自然地名|交通地名|城市中心|标志性建筑物|热点地名";
    }
    if (poiTypes == UCarMapSearchPOIType_SOS)
    {
        return @"产业园|楼宇|标志性建筑物|交通地名|热点地名";
    }
    if (poiTypes == UCarMapSearchPOIType_VIO) {
        return @"热点地名";
    }
    NSArray* s_poiCodes = @[ @[@"2003"], @[@"05"], @[@"0101", @"0103"], @[@"1509"] ];
    NSMutableArray* codes = [[NSMutableArray alloc] init];
    for ( NSInteger i = 0; i < 4; ++i )
    {
        if ( poiTypes & (1 << i) )
        {
            [codes addObjectsFromArray:s_poiCodes[i]];
        }
    }
    return [codes componentsJoinedByString:@"|"];
}

@end
