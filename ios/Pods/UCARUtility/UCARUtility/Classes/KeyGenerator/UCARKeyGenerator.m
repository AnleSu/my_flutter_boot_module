//
//  UCARKeyGenerator.c
//  UCar
//
//  Created by KouArlen on 16/4/6.
//  Copyright © 2016年 zuche. All rights reserved.
//

#include "UCARKeyGenerator.h"
#include <CommonCrypto/CommonCrypto.h>

NSString *ucar_generateKey(const char *method, unsigned char *bytes, size_t length) {
    unsigned char methodSha[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(method, (CC_LONG)strlen(method), methodSha);

    char *key = (char *)malloc(length + 1);
    bzero(key, length + 1);

    size_t index = length;
    if (length > CC_SHA1_DIGEST_LENGTH) {
        for (int i = CC_SHA1_DIGEST_LENGTH; i < length; i++) {
            key[i] = bytes[i];
        }

        index = CC_SHA1_DIGEST_LENGTH;
    }

    for (int i = 0; i < index; i++) {
        key[i] = bytes[i] ^ methodSha[i];
    }

    NSString *keyStr = [NSString stringWithCString:key encoding:NSUTF8StringEncoding];
    free(key);
    return keyStr;
}

void ucar_getKeyObfuscator(const char *method, const char *password) {
    size_t length = strlen(password);

    printf("-------begin----------\n");
    printf("length: %zu\n", length);

    unsigned char passwd[length];

    for (int i = 0; i < length; i++) {
        passwd[i] = password[i];
    }

    unsigned char methodSha[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(method, (CC_LONG)strlen(method), methodSha);

    unsigned char obfuscator[length];

    size_t index = length;
    if (length > CC_SHA1_DIGEST_LENGTH) {
        for (int i = CC_SHA1_DIGEST_LENGTH; i < length; i++) {
            obfuscator[i] = passwd[i];
        }

        index = CC_SHA1_DIGEST_LENGTH;
    }

    for (int i = 0; i < index; i++) {
        obfuscator[i] = passwd[i] ^ methodSha[i];
    }

    for (int i = 0; i < length; i++) {
        printf("0x%X,\t\t", obfuscator[i]);
        if ((i + 1) % 4 == 0) {
            printf("\n");
        }
    }
    printf("-------end----------\n");
}

NSString *ucar_generateRandomKey(int length) {
    // simple, foolish
    // don't use char, encoding twice using UTF-8 will generate unreadable code
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *key = [[NSMutableString alloc] initWithCapacity:length];
    for (int i = 0; i < length; i++) {
        u_int32_t random = arc4random_uniform(62);
        [key appendString:[letters substringWithRange:NSMakeRange(random, 1)]];
    }
    return [key copy];
}
