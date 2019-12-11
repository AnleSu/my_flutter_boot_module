//
//  GZipUtil.h
//  UCar
//
//  Created by  zhangfenglin on 15/6/1.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (GZIP)

- (NSData *)gzCompress;
- (NSData *)gzDecompress;
- (NSString *)gzCompressToString;
- (NSData *)gzDecompressFromISO;
@end
