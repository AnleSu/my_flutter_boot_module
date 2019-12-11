//
//  UCARDeviceToken.h
//  UCARDeviceToken
//
//  Created by linux on 2018/12/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 获取设备标识
 */
@interface UCARDeviceToken : NSObject


/**
 设置自定义deviceUUID，该值会优先使用
 @note 如果需要使用自定义deviceUUID，务必在使用前设置
 */
@property (nonatomic, nullable, strong) NSString *customDeviceUUID;

/**
 单例

 @return token实例
 */
+ (nonnull instancetype)sharedToken;

/**
 deviceUUID
 
 @return the unique device id
 */
+ (NSString *)deviceUUID;

/**
 共享的设备号，同一个teamId是才可以使用
 需要在工程开启keychain sharing时添加
 com.szzc.shared项

 @return 共享的设备号
 */
+ (NSString *)sharedDeviceUUID;

//当不需要自定义deviceUUID时，统一使用上面的方法即可
//下面的方法仅在使用自定义deviceUUID且需要与其他App取值一致时使用。

/**
 keyChainDeviceToken

 @return keyChainDeviceToken
 */
+ (nonnull NSString *)keyChainDeviceToken;



@end

NS_ASSUME_NONNULL_END
