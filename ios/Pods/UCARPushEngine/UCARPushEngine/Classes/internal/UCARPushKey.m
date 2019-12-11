//
//  UCARPushKey.m
//  UCARPushDemo
//
//  Created by North on 10/27/16.
//  Copyright © 2016 North. All rights reserved.
//

#import "UCARPushKey.h"
#import <UCARUtility/UCARKeyGenerator.h>

NSString *ucar_wtfpush() {
    const char *method = __FUNCTION__;

    unsigned char key[] = {
        0x3F, 0x8E, 0x76, 0x20, 0xB5, 0x14, 0x31, 0x83, 0x39, 0x29, 0x75, 0x29, 0xDD,
        0x8,  0x6D, 0x33, 0x15, 0x97, 0xE2, 0x55, 0x70, 0x46, 0x57, 0x45, 0x38,
    };

    return ucar_generateKey(method, key, 25);
}
