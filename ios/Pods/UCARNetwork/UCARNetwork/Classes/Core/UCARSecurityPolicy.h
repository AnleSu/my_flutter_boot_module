//
//  UCARSecurityPolicy.h
//  UCARNetwork
//
//  Created by North on 12/2/16.
//  Copyright © 2016 szzc. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

/**
 安全策略，用于 httpdns
 */
@interface UCARSecurityPolicy : AFSecurityPolicy

/**
 保存ip与domain的映射关系
 @note 此中保存的IP与域名为多对一关系，即一个IP对应一个域名，一个域名可对应多个IP。
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *IPs;

@end
