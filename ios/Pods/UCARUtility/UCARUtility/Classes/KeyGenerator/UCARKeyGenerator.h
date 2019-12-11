//
//  UCARKeyGenerator.h
//  UCar
//
//  Created by KouArlen on 16/4/6.
//  Copyright © 2016年 zuche. All rights reserved.
//

#ifndef UCARKeyGenerator_h
#define UCARKeyGenerator_h

#import <Foundation/Foundation.h>


/**
 解析一个混淆后的key

 @param method 因子
 @param bytes char string
 @param length bytes length
 @return orginal key
 */
FOUNDATION_EXTERN NSString *ucar_generateKey(const char *method, unsigned char *bytes, size_t length);


/**
 打印混淆后的 char string

 @param method 因子
 @param password orginal key
 */
FOUNDATION_EXTERN void ucar_getKeyObfuscator(const char *method, const char *password);


/**
 获取一个随机key

 @param length 长度
 @return 随机key
 @discussion 只包括 a-z, A-Z, 0-9
 */
FOUNDATION_EXTERN NSString *ucar_generateRandomKey(int length);

#endif /* UCARKeyGenerator_h */
