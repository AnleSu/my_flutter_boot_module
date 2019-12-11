//
//  UCARTimeLineView.m
//  UCar
//
//  Created by KouArlen on 15/6/17.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import "UCARTimeLineView.h"
#import "UCARUIKitTools.h"

@interface UCARTimeLineView ()

@property (nonatomic, assign) BOOL isTop;
@property (nonatomic, assign) BOOL isBottom;

@end

@implementation UCARTimeLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isTop = NO;
        _isBottom = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)isTop:(BOOL)isTop isBottom:(BOOL)isBottom
{
    _isTop = isTop;
    _isBottom = isBottom;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    //timeline部分
    UIColor *timeLineColor = UCAR_ColorFromHexString(@"#fbae1a");
    //画线
    CGContextSetStrokeColorWithColor(context, timeLineColor.CGColor);
    CGContextSetLineWidth(context, 2.0);
    
    CGFloat height = self.bounds.size.height;
    
    if (!_isTop) {
        CGPoint top = CGPointMake(6, 0);
        CGPoint cycleTop = CGPointMake(6, 16 - 6 - 5);
        UIBezierPath *topPath = [UIBezierPath bezierPath];
        [topPath moveToPoint:top];
        [topPath addLineToPoint:cycleTop];
        CGContextAddPath(context, topPath.CGPath);
    }
    
    if (!_isBottom) {
        CGPoint cycleBottom = CGPointMake(6, 16 + 6 + 5);
        CGPoint bottom = CGPointMake(6, height);
        UIBezierPath *bottomPath = [UIBezierPath bezierPath];
        [bottomPath moveToPoint:cycleBottom];
        [bottomPath addLineToPoint:bottom];
        CGContextAddPath(context, bottomPath.CGPath);
    }
    
    CGContextStrokePath(context);
    
    //画圆
    CGContextSetFillColorWithColor(context, timeLineColor.CGColor);
    CGPoint center = CGPointMake(6, 16);
    UIBezierPath *cyclePath = [UIBezierPath bezierPath];
    [cyclePath moveToPoint:CGPointMake(center.x, center.y+6)];
    [cyclePath addArcWithCenter:center radius:6 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [cyclePath closePath];
    CGContextAddPath(context, cyclePath.CGPath);
    CGContextFillPath(context);
    
    //it does nothing, but I write here.
    [super drawRect:rect];
}

@end



