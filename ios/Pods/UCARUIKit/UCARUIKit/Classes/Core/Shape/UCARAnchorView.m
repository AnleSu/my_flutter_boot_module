//
//  UCARAnchorView.m
//  UCar
//
//  Created by KouArlen on 15/6/17.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import "UCARAnchorView.h"
#import "UCARUIKitTools.h"

@implementation UCARAnchorView

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
    
    UIColor *lineColor = UCAR_ColorFromHexString(@"#cccccc");
    CGFloat lineWidth = 1.0;
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGPoint anchor = CGPointMake(width, height/2);
    CGPoint leftTop = CGPointMake(anchor.x-5, anchor.y-5);
    CGPoint leftBottom = CGPointMake(anchor.x-5, anchor.y+5);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:leftTop];
    [path addLineToPoint:anchor];
    [path addLineToPoint:leftBottom];
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
    
    [super drawRect:rect];
}

@end
