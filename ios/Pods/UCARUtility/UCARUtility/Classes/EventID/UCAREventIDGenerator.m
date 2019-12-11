//
//  UCAREventIDGenerator.m
//  Pods
//
//  Created by North on 16/8/31.
//
//

#import "UCAREventIDGenerator.h"

NSString *const UCAREventIDStoreKey = @"UCAREventIDStoreKey";

@interface UCAREventIDGenerator ()

@property (nonatomic) long eventID;

@end

@implementation UCAREventIDGenerator

+ (instancetype)shared {
    static id sharedUtil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedUtil = [[self alloc] init];
    });
    return sharedUtil;
}

+ (void)initEventID:(long)eventID {
    [[UCAREventIDGenerator shared] initEventID:eventID];
}

+ (NSString *)generateEventID {
    return [[UCAREventIDGenerator shared] generateEventID];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _eventID = 0;
    }
    return self;
}

- (void)initEventID:(long)eventID {
    _eventID = eventID;
}

- (NSString *)generateEventID {
    _eventID++;
    if (_eventID > LONG_MAX - 20000) {
        _eventID = 0;
    }
    return @(_eventID).stringValue;
}

@end
