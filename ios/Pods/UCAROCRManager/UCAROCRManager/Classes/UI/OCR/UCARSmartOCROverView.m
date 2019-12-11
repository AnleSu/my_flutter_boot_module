//
//  OverView.m
//  TestCamera
//

#import "UCARSmartOCROverView.h"
#import <CoreText/CoreText.h>
#import "OCRMacroColor.h"

@implementation UCARSmartOCROverView{
    CGRect _smallRect;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setSmallrect:(CGRect)smallrect{
    _smallRect = smallrect;
    [self setNeedsDisplay];
    
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [UIColorFromRGB(0xF12E49) set];
    //获得当前画布区域
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //设置线的宽度
    CGContextSetLineWidth(currentContext, 2.0f);
    
    CGFloat lineLong = 25;
    
    CGContextMoveToPoint(currentContext, CGRectGetMinX(_smallRect), CGRectGetMinY(_smallRect));
    CGContextAddLineToPoint(currentContext, CGRectGetMinX(_smallRect)+lineLong, CGRectGetMinY(_smallRect));
    
    CGContextMoveToPoint(currentContext, CGRectGetMaxX(_smallRect)-lineLong, CGRectGetMinY(_smallRect));
    CGContextAddLineToPoint(currentContext, CGRectGetMaxX(_smallRect), CGRectGetMinY(_smallRect));
    CGContextAddLineToPoint(currentContext, CGRectGetMaxX(_smallRect), CGRectGetMinY(_smallRect)+lineLong);

    CGContextMoveToPoint(currentContext, CGRectGetMaxX(_smallRect), CGRectGetMaxY(_smallRect)-lineLong);
    CGContextAddLineToPoint(currentContext, CGRectGetMaxX(_smallRect), CGRectGetMaxY(_smallRect));
    CGContextAddLineToPoint(currentContext, CGRectGetMaxX(_smallRect)-lineLong, CGRectGetMaxY(_smallRect));
    
    CGContextMoveToPoint(currentContext, CGRectGetMinX(_smallRect)+lineLong, CGRectGetMaxY(_smallRect));
    CGContextAddLineToPoint(currentContext, CGRectGetMinX(_smallRect), CGRectGetMaxY(_smallRect));
    CGContextAddLineToPoint(currentContext, CGRectGetMinX(_smallRect), CGRectGetMaxY(_smallRect)-lineLong);
    
    CGContextMoveToPoint(currentContext, CGRectGetMinX(_smallRect), CGRectGetMinY(_smallRect)+lineLong);
    CGContextAddLineToPoint(currentContext, CGRectGetMinX(_smallRect), CGRectGetMinY(_smallRect));


    
    CGContextStrokePath(currentContext);
}


 

@end
