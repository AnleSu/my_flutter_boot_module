//
//  UCarMessage.m
//  UCARClientSocket
//
//  Created by  zhangfenglin on 15/9/28.
//  Copyright (c) 2015年  zhangfenglin. All rights reserved.
//

#import "UCarMessage.h"

@implementation UCarMessage

- (instancetype)init {
    self = [super init];
    if (self) {
        _version = 1;
        _type = 0;
        _message = @"";
        _businessType = 0;
        _uuid = nil;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *discription = [NSMutableString string];

    [discription appendFormat:@"message version = %d\n", self.version];
    [discription appendFormat:@"message type = %d\n", self.type];
    [discription appendFormat:@"business type = %d\n", self.businessType];
    [discription appendFormat:@"uuid = %@\n", self.uuid];
    [discription appendFormat:@"message = %@", self.message];

    return discription;
}

@end
