//
//  UCARAnchorLineView.m
//  UCar
//
//  Created by Arlen on 16/7/21.
//  Copyright © 2016年 zuche. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "UCARAnchorLineView.h"
#import "UCARUIKitTools.h"

@implementation UCARAnchorLineView

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
    
    
    
    CGFloat width = self.bounds.size.width;
    
    CGFloat height = self.bounds.size.height;
    
    //先画三角
    CGContextSetLineWidth(context, lineWidth*2);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGPoint corner = CGPointMake(width-9, height/2);
    CGPoint topLeft = CGPointMake(corner.x-5, corner.y-5);
    CGPoint bottomLeft = CGPointMake(corner.x-5, corner.y+5);
    UIBezierPath *anchorPath = [UIBezierPath bezierPath];
    [anchorPath moveToPoint:topLeft];
    [anchorPath addLineToPoint:corner];
    [anchorPath addLineToPoint:bottomLeft];
    CGContextAddPath(context, anchorPath.CGPath);
    CGContextStrokePath(context);
    
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGPoint lineTop = CGPointMake(width-lineWidth, lineWidth/2);
    CGPoint lineBottom = CGPointMake(width-lineWidth, height-lineWidth/2);
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:lineTop];
    [linePath addLineToPoint:lineBottom];
    CGContextAddPath(context, linePath.CGPath);
    CGContextStrokePath(context);
    
    [super drawRect:rect];
}


@end
