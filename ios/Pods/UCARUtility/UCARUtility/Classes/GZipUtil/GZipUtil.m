//
//  GZipUtil.m
//  UCar
//
//  Created by  zhangfenglin on 15/6/1.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import "GZipUtil.h"
#import <zlib.h>

@implementation NSData (GZIP)

- (NSData *)gzCompress {
    if ([self length] == 0)
        return self;

    z_stream strm;

    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in = (Bytef *)[self bytes];
    strm.avail_in = (unsigned int)[self length];

    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15 + 16), 8, Z_DEFAULT_STRATEGY) != Z_OK)
        return nil;

    NSMutableData *compressed = [NSMutableData dataWithLength:16384]; // 16K chunks for expansion

    do {

        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy:16384];

        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (unsigned int)([compressed length] - strm.total_out);

        deflate(&strm, Z_FINISH);

    } while (strm.avail_out == 0);

    deflateEnd(&strm);

    [compressed setLength:strm.total_out];
    return [NSData dataWithData:compressed];
}

- (NSString *)gzCompressToString {
    NSData *data = [self gzCompress];
    NSStringEncoding isoEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
    NSString *str = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:isoEncoding];
    return str;
}

- (NSData *)gzDecompress {
    if ([self length] == 0)
        return self;

    unsigned long full_length = [self length];
    unsigned long half_length = [self length] / 2;
    NSMutableData *decompressed = [NSMutableData dataWithLength:full_length + half_length];

    BOOL done = NO;
    int status;

    z_stream strm;

    strm.next_in = (Bytef *)[self bytes];
    strm.avail_in = (uInt)[self length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;

    if (inflateInit2(&strm, (15 + 32)) != Z_OK)
        return nil;

    while (!done) {
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy:half_length];

        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([decompressed length] - strm.total_out);

        // Inflate another chunk.

        status = inflate(&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END)
            done = YES;
        else if (status != Z_OK)
            break;
    }

    if (inflateEnd(&strm) != Z_OK)
        return nil;
    // Set real length.

    if (done) {

        [decompressed setLength:strm.total_out];
        return [NSData dataWithData:decompressed];
    }
    return nil;
}

- (NSData *)gzDecompressFromISO {
    NSStringEncoding isoEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
    NSString *str = [[NSString alloc] initWithBytes:[self bytes] length:[self length] encoding:isoEncoding];
    return [[str dataUsingEncoding:NSUTF8StringEncoding] gzDecompress];
}
@end
