//
//  UCARDrawLine.m
//
//
//  Created by szq on 2019/4/25.
//

#import "ZCComponentDrawLine.h"

@implementation ZCComponentDrawLine

/**
 *  画线
 */
- (void)drawLine{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, _width);
    CGContextSetStrokeColorWithColor(context, _color);
    CGContextMoveToPoint(context, _from_Point.x, _from_Point.y);
    CGContextAddLineToPoint(context, _to_Point.x, _to_Point.y);
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end
