//
//  UCarMapSearchImpl.h
//  UCar
//
//  Created by huangyi on 9/1/16.
//  Copyright © 2016 huangyi. All rights reserved.
//

#import <UCarMapFundation/UCarMapFundation.h>
#import "UCarMapSearchService.h"

@protocol UCarMapSearchImplDelegate <NSObject>
@required

- (void)searchDrivingRouteComplete:(UCarMapPath*)path error:(NSError*)err;

- (void)searchGeocodeComplete:(NSArray<UCarMapAddress*>*)result error:(NSError*)err;

- (void)searchReverseGeocodeComplete:(NSArray<UCarMapAddress*>*)result error:(NSError*)err;

- (void)searchPOIComplete:(NSArray<UCarMapAddress*>*)result error:(NSError*)err;

- (void)searchKeywordComplete:(NSArray<UCarMapAddress*>*)result error:(NSError*)err;

- (void)searchWalkingRouteComplete:(UCarMapPath*)path error:(NSError*)err;

- (void)searchTransitRouteComplete:(NSArray<UCarMapTransit*>*)transits error:(NSError*)err;

@end

@protocol UCarMapSearchImpl <NSObject>

@required
@property (nonatomic, weak) id<UCarMapSearchImplDelegate>  delegate;

- (void)searchDrivingRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination wayPoints:(NSArray*)wayPoints withStrategy:(UCarMapSearchRouteStrategy)strategy;

- (void)searchGeoCode:(NSString*)city address:(NSString*)address;

- (void)searchReverseGeoCode:(UCarMapCoordinate*)coordinate;

- (void)searchPOI:(UCarMapCoordinate*)coordinate poiTypes:(NSInteger)poiTypes distance:(CGFloat)distance pageCount:(NSInteger)count;

- (void)searchKeyword:(NSString*)keyword cityName:(NSString*)city poiTypes:(NSInteger)poiTypes;

- (void)searchWalkingRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination;

- (void)searchTransitRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination city:(NSString *)city nightFlag:(BOOL)nightFlag;

- (void)searchTransitRouteFrom:(UCarMapCoordinate*)origin to:(UCarMapCoordinate*)destination city:(NSString *)city DestinationCity:(NSString *)destCity nightFlag:(BOOL)nightFlag;
@end
