//
//  UCARShareItem.m
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import "UCARShareItem.h"

@implementation UCARShareItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

// 通过 shareType 创建对应实例
+ (instancetype)itemWithShareType:(UCARShareType)shareType {
    UCARShareItem* item = [[self alloc] init];
    item->_shareType = shareType;
    
    // 微博专用
    if (shareType == UCARShareTypeSina) {
        item->_objectID = [NSUUID UUID].UUIDString;
    }
    
    return item;
}

#pragma mark -
#pragma mark - lazy
- (NSString *)fileExtension {
    if (_fileExtension.length == 0) {
        // 默认是 pdf
        _fileExtension = @"pdf";
    }
    return _fileExtension;
}

@end
