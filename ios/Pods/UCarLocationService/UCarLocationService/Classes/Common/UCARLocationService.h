//
//  UCARLocationService.h
//  UCarDriver
//
//  Created by huangyi on 11/14/16.
//  Copyright © 2016 szzc. All rights reserved.
//

#import <UCarMapFundation/UCarMapFundation.h>

//! Project version number for UCarLocationService.
FOUNDATION_EXPORT double UCarLocationServiceVersionNumber;

//! Project version string for UCarLocationService.
FOUNDATION_EXPORT const unsigned char UCarLocationServiceVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <UCarLocationService/PublicHeader.h>

@protocol UCarLocationObserver;

// 定位状态
typedef NS_ENUM(NSInteger, UCARLocationServiceStatus) {
    UCARLocationServiceStatus_Stop        = 0,
    UCARLocationServiceStatus_Starting    = 1,     // 定位中
    UCARLocationServiceStatus_SignalWeak  = 2,     // 定位不准,信号弱
    UCARLocationServiceStatus_Normal      = 3,     // 定位正常
    UCARLocationServiceStatus_Error       = 4      // 定位失败,系统报错
};

@interface UCARLocationService : NSObject

/**
 * 指定定位是否会被系统自动暂停。默认为NO。
 */
@property(nonatomic, readwrite) BOOL                    pausesLocationUpdatesAutomatically;

/**
 * 是否允许后台定位。默认为NO。
 * @note 只在iOS 9.0及之后起作用。设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
 */
@property(nonatomic, readwrite) BOOL                    allowsBackgroundLocationUpdates;

/**
 * 是否已经开始定位。
 */
@property(nonatomic, readonly) BOOL                     haveStart;

/**
 * 使用的地图模式, 高德或百度。
 */
@property(nonatomic, readwrite) UCarMapImplementType    implementType;

/**
 * 定位精度阈值,区分准与不准状态用标准, 默认60, 单位米
 */
@property(nonatomic, assign) uint32_t    accuracyThreshold;

/**
 * 当前最新的定位位置。
 * @note 该位置同观察者自己设置的distancefilter 和精度无关, 只代表当前最新的位置。
 */
@property(nonatomic, readonly) UCarMapLocation*         currentLocation;

/**
 * 当前的定位状态。
 */
@property(nonatomic, readonly) UCARLocationServiceStatus         status;

+ (instancetype)sharedInstance;

- (void)addLocationObserver:(id<UCarLocationObserver>)observer;
- (void)removeLocationObserver:(id<UCarLocationObserver>)observer;

/**
 * 开始定位
 * @note 全局函数,会影响到所有观察者。
 */
- (void)startUpdatingLocation;

/**
 * 停止定位
 * @note 全局函数,会影响到所有观察者, 如当前不需要定位, 请同过removeLocationObserver的方式移除自身。
 */
- (void)stopUpdatingLocation;

- (void)requestAlwaysAuthorization;

@end


@protocol UCarLocationObserver <NSObject>

@optional
- (void)locationService:(UCARLocationService *)service didFailWithError:(NSError *)error;
- (void)locationService:(UCARLocationService *)service didUpdateLocation:(UCarMapLocation *)location;
- (void)locationService:(UCARLocationService *)service didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

/**
 * 定位距离过滤
 * @note 如果不实现则不过滤。
 */
- (CLLocationDistance)distanceFilterWithlocationService:(UCARLocationService *)service;

/**
 * 定位精度过滤
 * @note 如果不实现则不过滤。
 */
- (CLLocationAccuracy)desiredAccuracyWithlocationService:(UCARLocationService *)service;

/**
 * 定位状态改变通知
 */
- (void)locationService:(UCARLocationService *)service didChangeStatus:(UCARLocationServiceStatus)status;

@end


