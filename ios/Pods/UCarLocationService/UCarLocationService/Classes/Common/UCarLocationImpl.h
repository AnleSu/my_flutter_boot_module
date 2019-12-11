//
//  UCarLocationImpl.h
//  UCarDriver
//
//  Created by huangyi on 11/14/16.
//  Copyright © 2016 szzc. All rights reserved.
//

#import <UCarMapFundation/UCarMapFundation.h>

@protocol UCarLocationImplDelegate;

@protocol UCarLocationImpl <NSObject>

@property(nonatomic, readwrite) CLLocationDistance      distanceFilter;
@property(nonatomic, readwrite) CLLocationAccuracy      desiredAccuracy;
@property(nonatomic, readwrite) BOOL                    pausesLocationUpdatesAutomatically;
@property(nonatomic, readwrite) BOOL                    allowsBackgroundLocationUpdates;
@property(nonatomic, weak) id<UCarLocationImplDelegate> delegate;

@property(nonatomic, readonly) UCarMapLocation*         currentLocation;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

- (void)requestAlwaysAuthorization;
@end

@protocol UCarLocationImplDelegate <NSObject>
@optional
@optional
- (void)locationImpl:(id<UCarLocationImpl>)service didFailWithError:(NSError *)error;
- (void)locationImpl:(id<UCarLocationImpl>)service didUpdateLocation:(UCarMapLocation *)location;
- (void)locationImpl:(id<UCarLocationImpl>)service didChangeAuthorizationStatus:(CLAuthorizationStatus)status;
@end

