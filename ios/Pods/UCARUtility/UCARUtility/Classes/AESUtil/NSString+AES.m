//
//  NSString+AES.m
//  AESDemo
//
//  Created by kkxz on 15/1/9.
//  Copyright (c) 2015年 kkxz. All rights reserved.
//

#import "NSData+Encryption.h"
#import "NSString+AES.h"

@implementation NSString (AES)
//加密
+ (NSString *)AESForEncry:(NSString *)message WithKey:(NSString *)key {
    if (!key || !message) {
        return message;
    }

    NSData *encryData = [[message dataUsingEncoding:NSUTF8StringEncoding] AES256ParmEncryptWithKey:key];
    if (encryData && encryData.length > 0) {
        NSString *base64EncryString =
            [encryData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        base64EncryString = [base64EncryString stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
        base64EncryString = [base64EncryString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        return base64EncryString;
    }
    return nil;
}

//解密
+ (NSString *)AESForDecry:(NSString *)message WithKey:(NSString *)key {
    if (!key || !message) {
        return message;
    }

    message = [message stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    message = [message stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    NSData *baseData = [[NSData alloc] initWithBase64EncodedString:message
                                                           options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *decryData = [baseData AES256ParmDecryptWithKey:key];
    if (decryData && decryData.length > 0) {
        NSString *base64DecryString = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
        return base64DecryString;
    }
    return nil;
}

@end
