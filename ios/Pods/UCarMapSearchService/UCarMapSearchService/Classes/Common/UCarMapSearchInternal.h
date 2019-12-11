//
//  UCarMapSearchInternal.h
//  UCar
//
//  Created by huangyi on 6/1/16.
//  Copyright © 2016 huangyi. All rights reserved.
//

#import "UCarMapTypes.h"
#import "UCarMapSearchService.h"

@interface UCarMapSearchRouteRequest : NSObject
@property (nonatomic, copy) UCarMapCoordinate*              origin;
@property (nonatomic, copy) UCarMapCoordinate*              destination;
@property (nonatomic, copy) NSArray*                        wayPoints;
@property (nonatomic, assign) UCarMapSearchRouteStrategy    strategy;
@end

@interface UCarMapSearchGeocodeRequest : NSObject
@property (nonatomic, copy) NSString*                       city;
@property (nonatomic, copy) NSString*                       address;
@end

@interface UCarMapSearchRGeocodeRequest : NSObject
@property (nonatomic, copy) UCarMapCoordinate*              coordinate;
@end

@interface UCarMapSearchPOIRequest : NSObject
@property (nonatomic, copy) UCarMapCoordinate*              coordinate;
@property (nonatomic, assign) NSInteger                     poiTypes;
@property (nonatomic, assign) CGFloat                       distance;
@property (nonatomic, assign) NSInteger                     pageCount;
@end

@interface UCarMapSearchKeywordRequest : NSObject
@property (nonatomic, strong) NSString*                     keyword;
@property (nonatomic, strong) NSString*                     city;
@property (nonatomic, assign) NSInteger                     poiTypes;
@end

@interface UCarMapSearchWalkingRouteRequest : NSObject
@property (nonatomic, copy) UCarMapCoordinate*              origin;
@property (nonatomic, copy) UCarMapCoordinate*              destination;
@end

@interface UCarMapSearchTransitRouteRequest : NSObject
@property (nonatomic, copy) UCarMapCoordinate*              origin;
@property (nonatomic, copy) UCarMapCoordinate*              destination;
@property (nonatomic, strong) NSString*                     city;
@property (nonatomic, strong) NSString*                     destCity;
@property (nonatomic, assign) BOOL                          nightFlag;
@end
