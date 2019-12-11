//
//  UCARLineView.m
//  UCar
//
//  Created by KouArlen on 15/6/17.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import "UCARLineView.h"
#import "UCARUIKitTools.h"

@implementation UCARLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UCAR_ColorFromHexString(@"#d9d9d9");
    }
    return self;
}

@end
