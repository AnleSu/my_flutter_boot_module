//
//  UCarEncryption.m
//  UCarNetwork
//
//  Created by david on 16/8/30.
//  Copyright © 2016年 UCarInc. All rights reserved.
//

#import "UCarLiveEncryption.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation UCarLiveEncryption

//加密
+ (NSData *)AES256ParmEncryptWithKey:(NSString *)key data:(NSData *)data
{
    if(data == nil || data.length == 0) { return nil; }
    
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = /*[self length]*/data.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          /*[self bytes]*/data.bytes, dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

//解密
+ (NSData *)AES256ParmDecryptWithKey:(NSString *)key data:(NSData *)data
{
    if(data == nil || data.length == 0) { return nil; }
    
//    message = [message stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
//    message = [message stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
//    NSData *baseData = [[NSData alloc] initWithBase64EncodedString:message options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = data.length;//[self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          /*[self bytes]*/data.bytes, dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

//加密
+(NSString *)AESForEncry:(NSString*)message WithKey:(NSString*)key
{
    if(message == nil || message.length == 0 || key == nil){
        return @"";
    }
    //NSData *encryData = [[message dataUsingEncoding:NSUTF8StringEncoding] AES256ParmEncryptWithKey:key];
    NSData *encryData = [UCarLiveEncryption AES256ParmEncryptWithKey:key data:[message dataUsingEncoding:NSUTF8StringEncoding]];
    if(encryData&&encryData.length>0){
        NSString * base64EncryString = [encryData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        base64EncryString = [base64EncryString stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
        base64EncryString = [base64EncryString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        return base64EncryString;
    }
    return nil;
}

//解密
+(NSString*)AESForDecry:(NSString*)message WithKey:(NSString*)key
{
    if(message == nil || message.length == 0 || key == nil){
        return @"";
    }
    message = [message stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    message = [message stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    NSData *baseData = [[NSData alloc] initWithBase64EncodedString:message options:NSDataBase64DecodingIgnoreUnknownCharacters];
    //NSData * decryData =  [baseData AES256ParmDecryptWithKey:key];
    NSData *decryData = [UCarLiveEncryption AES256ParmDecryptWithKey:key data:baseData];
    if(decryData&&decryData.length>0){
        NSString * base64DecryString = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
        return base64DecryString;
    }
    return nil;
}

@end
