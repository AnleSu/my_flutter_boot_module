//
//  UCARLocationAMapImpl.m
//  UCarDriver
//
//  Created by huangyi on 11/14/16.
//  Copyright © 2016 szzc. All rights reserved.
//

#import "UCARLocationAMapImpl.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface UCARLocationAMapImpl() <AMapLocationManagerDelegate, CLLocationManagerDelegate>
{
    AMapLocationManager*                amapLocationManager;
    CLLocationManager*                  locationManager;
}

- (UCarMapLocation*)convertLocation:(CLLocation*)location;
@end

@implementation UCARLocationAMapImpl

@synthesize delegate;
@synthesize currentLocation;

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        [[AMapServices sharedServices] setEnableHTTPS:YES];
        [AMapServices sharedServices].apiKey = [UCarMapFundation sharedInstance].keys[AMAP_KEY];
        amapLocationManager = [[AMapLocationManager alloc] init];
        amapLocationManager.delegate = self;
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
    }
    return self;
}

- (CLLocationDistance)distanceFilter
{
    return amapLocationManager.distanceFilter;
}

- (void)setDistanceFilter:(CLLocationDistance)distance
{
    amapLocationManager.distanceFilter = distance;
}

- (CLLocationAccuracy)desiredAccuracy
{
    return amapLocationManager.desiredAccuracy;
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)accuracy
{
    amapLocationManager.desiredAccuracy = accuracy;
}

- (BOOL)pausesLocationUpdatesAutomatically
{
    return amapLocationManager.pausesLocationUpdatesAutomatically;
}

- (void)setPausesLocationUpdatesAutomatically:(BOOL)bPause
{
    amapLocationManager.pausesLocationUpdatesAutomatically = bPause;
}

- (BOOL)allowsBackgroundLocationUpdates
{
    return amapLocationManager.allowsBackgroundLocationUpdates;
}

- (void)setAllowsBackgroundLocationUpdates:(BOOL)bAllow
{
    amapLocationManager.allowsBackgroundLocationUpdates = bAllow;
}

- (void)startUpdatingLocation
{
    [amapLocationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
    [amapLocationManager stopUpdatingLocation];
}

- (void)requestAlwaysAuthorization
{
    [locationManager requestAlwaysAuthorization];
}

#pragma mark - AMapLocationManagerDelegate
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    if ( [delegate respondsToSelector:@selector(locationImpl:didFailWithError:)] )
    {
        [delegate locationImpl:self didFailWithError:error];
    }
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    currentLocation = [self convertLocation:location];
    if ( [delegate respondsToSelector:@selector(locationImpl:didUpdateLocation:)] )
    {
        [delegate locationImpl:self didUpdateLocation:currentLocation];
    }
}

- (void)amapLocationManager:(AMapLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ( [delegate respondsToSelector:@selector(locationImpl:didChangeAuthorizationStatus:)] )
    {
        [delegate locationImpl:self didChangeAuthorizationStatus:status];
    }
}

#pragma mark - Private
- (UCarMapLocation*)convertLocation:(CLLocation*)location
{
    UCarMapLocation* ucarLocation = [[UCarMapLocation alloc] init];
    ucarLocation.coordinate = [[UCarMapCoordinate alloc] init];
    ucarLocation.coordinate.amapCoordinate = location.coordinate;
    ucarLocation.accuracy = location.horizontalAccuracy;
    ucarLocation.altitude = location.altitude;
    ucarLocation.heading = location.course;
    ucarLocation.speed = location.speed;
    ucarLocation.timestamp = location.timestamp;;
    return ucarLocation;
}

@end
