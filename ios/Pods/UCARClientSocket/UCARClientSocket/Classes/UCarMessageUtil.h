//
//  UCarMessageUtil.h
//  UCARClientSocket
//
//  Created by  zhangfenglin on 15/9/28.
//  Copyright (c) 2015年  zhangfenglin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UCarMessage;
@interface UCarMessageUtil : NSObject

- (UCarMessage *)decodeData:(NSData *)data withKey:(NSString *)KEY_AES128;
- (NSData *)encodeMessage:(UCarMessage *)msg withKey:(NSString *)KEY_AES128;
@end
