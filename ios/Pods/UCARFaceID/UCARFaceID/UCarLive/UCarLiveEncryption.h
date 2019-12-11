//
//  UCarEncryption.h
//  UCarNetwork
//
//  Created by david on 16/8/30.
//  Copyright © 2016年 UCarInc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCarLiveEncryption : NSObject

+ (NSData *)AES256ParmEncryptWithKey:(NSString *)key data:(NSData *)data;
+ (NSData *)AES256ParmDecryptWithKey:(NSString *)key data:(NSData *)data;

+(NSString *)AESForEncry:(NSString*)message WithKey:(NSString*)key;
+(NSString*)AESForDecry:(NSString*)message WithKey:(NSString*)key;

@end
