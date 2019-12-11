//
//  NSData+Encryption.h
//  AESDemo
//
//  Created by kkxz on 15/1/8.
//  Copyright (c) 2015年 kkxz. All rights reserved.
//加密解密处理类

#import <Foundation/Foundation.h>

@interface NSData (Encryption)
- (NSData *)AES256ParmEncryptWithKey:(NSString *)key;
- (NSData *)AES256ParmDecryptWithKey:(NSString *)key;
@end