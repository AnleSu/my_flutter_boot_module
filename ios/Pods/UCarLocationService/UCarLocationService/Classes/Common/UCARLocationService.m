//
//  UCARLocationService.m
//  UCarDriver
//
//  Created by huangyi on 11/14/16.
//  Copyright © 2016 szzc. All rights reserved.
//

#import "UCARLocationService.h"
#import "UCarLocationImplFactory.h"
#import "UCarLBSTools.h"

#pragma mark - UCARLocationServiceObserverItem

@interface UCARLocationServiceObserverItem : NSObject

@property (nonatomic, weak) id<UCarLocationObserver> observer;

@property (nonatomic, strong) UCarMapLocation *lastUpdateLocation;

@end

@implementation UCARLocationServiceObserverItem

@end

#pragma mark - UCARLocationService

@interface UCARLocationService() <UCarLocationImplDelegate>
{
    NSHashTable*                    observers;
    id<UCarLocationImpl>            impl;
}

@end

@implementation UCARLocationService

@synthesize pausesLocationUpdatesAutomatically;
@synthesize allowsBackgroundLocationUpdates;
@synthesize implementType;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static UCARLocationService *instance = nil;
    dispatch_once( &onceToken, ^{
        instance = [[UCARLocationService alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        observers = [[NSHashTable alloc] initWithOptions:NSHashTableStrongMemory capacity:64];
        implementType = UCarMapImplementType_None;
        self.accuracyThreshold = 60;
    }
    return self;
}

- (void)setPausesLocationUpdatesAutomatically:(BOOL)bPause
{
    pausesLocationUpdatesAutomatically = bPause;
    impl.pausesLocationUpdatesAutomatically = bPause;
}

- (void)setAllowsBackgroundLocationUpdates:(BOOL)bAllow
{
    allowsBackgroundLocationUpdates = bAllow;
    impl.allowsBackgroundLocationUpdates = bAllow;
}

- (void)setImplementType:(UCarMapImplementType)type
{
    if ( type != implementType )
    {
        implementType = type;
        [UCarMapType setMapType:type];
        if ( impl )
        {
            [impl stopUpdatingLocation];
            impl = nil;
        }
        impl = [UCarLocationImplFactory GetLocationImpl:type];
        if ( impl )
        {
            impl.delegate = self;
            impl.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically;
            impl.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates;
        }
    }
}

- (UCarMapLocation*)currentLocation
{
    return impl.currentLocation;
}

- (void)addLocationObserver:(id<UCarLocationObserver>)observer
{
    if(![self haveAddObserver:observer]) {
        UCARLocationServiceObserverItem *item = [[UCARLocationServiceObserverItem alloc] init];
        item.observer = observer;
        item.lastUpdateLocation = nil;
        [observers addObject:item];
        if ( [observer respondsToSelector:@selector(locationService:didUpdateLocation:)])
        {
            [observer locationService:self didUpdateLocation:self.currentLocation];
        }
        
        if([observer respondsToSelector:@selector(locationService:didChangeStatus:)]){
            [observer locationService:self didChangeStatus:self.status];
        }
    }
}

- (void)removeLocationObserver:(id<UCarLocationObserver>)observer
{
    for (UCARLocationServiceObserverItem *item in observers) {
        if(item.observer == observer) {
            [observers removeObject:item];
            break;
        }
    }
}

- (void)startUpdatingLocation
{
    if (!self.haveStart) {
        [impl startUpdatingLocation];
        _haveStart = YES;
        _status = UCARLocationServiceStatus_Starting;
        [self NotifyStatusChange];
    }
}

- (void)stopUpdatingLocation
{
    if (self.haveStart) {
        [impl stopUpdatingLocation];
        _haveStart = NO;
        _status = UCARLocationServiceStatus_Stop;
        [self NotifyStatusChange];
    }
}

- (void)requestAlwaysAuthorization
{
    [impl requestAlwaysAuthorization];
}

- (BOOL)haveAddObserver:(id<UCarLocationObserver>)observer {
    for (UCARLocationServiceObserverItem *item in observers) {
        if (item.observer == observer) {
            return YES;
        }
    }
    return NO;
}

- (void)NotifyStatusChange {
    for (UCARLocationServiceObserverItem *item in observers) {
        id <UCarLocationObserver> observer = item.observer;
        if ([observer respondsToSelector:@selector(locationService:didChangeStatus:)]) {
            [observer locationService:self didChangeStatus:self.status];
        }
    }
}

#pragma mark - UCarLocationImplDelegate
- (void)locationImpl:(id<UCarLocationImpl>)service didFailWithError:(NSError *)error
{
    _status = UCARLocationServiceStatus_Error;
    [self NotifyStatusChange];
    for (UCARLocationServiceObserverItem *item in observers) {
        id <UCarLocationObserver> observer = item.observer;
        if ( [observer respondsToSelector:@selector(locationService:didFailWithError:)] )
        {
            [observer locationService:self didFailWithError:error];
        }
    }
}

- (void)locationImpl:(id<UCarLocationImpl>)service didUpdateLocation:(UCarMapLocation *)location
{
    for (UCARLocationServiceObserverItem *item in observers) {
        BOOL needUpdate = YES;
        id <UCarLocationObserver> observer = item.observer;
        CLLocationDistance distance = -1;
        CLLocationAccuracy accuracy = 99999; //location 精度一般最大2000m左右, 先设一个特大值, 保证默认情况下不过滤
        if ([observer respondsToSelector:@selector(distanceFilterWithlocationService:)]) {
            distance = [observer distanceFilterWithlocationService:self];
        }
        if ([observer respondsToSelector:@selector(desiredAccuracyWithlocationService:)]) {
            accuracy = [observer desiredAccuracyWithlocationService:self];
        }
        //判断是否需要进行距离过滤
        if(item.lastUpdateLocation != nil) {
            double offset;
            LBSToolDistance(item.lastUpdateLocation.coordinate.coordinate.latitude, item.lastUpdateLocation.coordinate.coordinate.longitude,location.coordinate.coordinate.latitude, location.coordinate.coordinate.longitude,&offset,NULL);
            if (offset < distance) {
                needUpdate = NO;
            }
        }
        //判断是否需要进行精度过滤
        if (location.accuracy > accuracy) {
            needUpdate = NO;
        }
        if (needUpdate && [observer respondsToSelector:@selector(locationService:didUpdateLocation:)] )
        {
            item.lastUpdateLocation = location;
            [observer locationService:self didUpdateLocation:location];
        }
        UCARLocationServiceStatus oldStatus = self.status;
        if (location.accuracy > self.accuracyThreshold) {
            _status = UCARLocationServiceStatus_SignalWeak;
        } else {
            _status = UCARLocationServiceStatus_Normal;
        }
        if (oldStatus != self.status) {
            [self NotifyStatusChange];
        }
    }
}

- (void)locationImpl:(id<UCarLocationImpl>)service didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    for (UCARLocationServiceObserverItem *item in observers) {
        id <UCarLocationObserver> observer = item.observer;
        if ( [observer respondsToSelector:@selector(locationService:didChangeAuthorizationStatus:)] )
        {
            [observer locationService:self didChangeAuthorizationStatus:status];
        }
    }
}

@end
