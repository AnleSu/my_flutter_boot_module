//
//  UCARDottedLineView.m
//  UCar
//
//  Created by KouArlen on 15/6/17.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import "UCARDottedLineView.h"
#import "UCARUIKitTools.h"

@implementation UCARDottedLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    UIColor *lineColor = UCAR_ColorFromHexString(@"#d9d9d9");
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGContextSetLineWidth(context, height);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGFloat lengths[] = {3, 2};
    CGContextSetLineDash(context, 0, lengths, 2);
    
    CGPoint left = CGPointMake(0, height/2);
    CGPoint right = CGPointMake(width, height/2);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:left];
    [path addLineToPoint:right];
    
    CGContextAddPath(context, path.CGPath);
    
    CGContextStrokePath(context);
    
    [super drawRect:rect];
}

@end
