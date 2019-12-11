//
//  NSString+AES.h
//  AESDemo
//
//  Created by kkxz on 15/1/9.
//  Copyright (c) 2015年 kkxz. All rights reserved.
//加密解密封装

#import <Foundation/Foundation.h>

@interface NSString (AES)
+ (NSString *)AESForEncry:(NSString *)message WithKey:(NSString *)key; //加密
+ (NSString *)AESForDecry:(NSString *)message WithKey:(NSString *)key; //解密
@end
