//
//  UCARSecurityPolicy.m
//  UCARNetwork
//
//  Created by North on 12/2/16.
//  Copyright © 2016 szzc. All rights reserved.
//

#import "UCARSecurityPolicy.h"

@implementation UCARSecurityPolicy

- (instancetype)init {
    self = [super init];
    if (self) {
        _IPs = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain {
    NSString *realDomain = _IPs[domain];
    if (realDomain) {
        domain = realDomain;
    }
    return [super evaluateServerTrust:serverTrust forDomain:domain];
}

@end
