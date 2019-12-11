//
//  UCARDragViewConfig.m
//  UCARDragTest-03-16
//
//  Created by 闫子阳 on 2018/3/22.
//  Copyright © 2018年 闫子阳. All rights reserved.
//

#import "UCARDragViewConfig.h"
#import "UCARDragView.h"

@implementation UCARDragViewConfig

- (instancetype)init
{
    if (self = [super init])
    {
        _header = [[UIView alloc] init];
        _headerHeight = 70;
        _headerInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _minTop = 50;
        _maxTop = 400;
    }
    return self;
}


@end
