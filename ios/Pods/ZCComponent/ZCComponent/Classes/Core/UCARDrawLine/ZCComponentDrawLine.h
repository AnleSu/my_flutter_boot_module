//
//  UCARDrawLine.h
//  
//
//  Created by szq on 2019/4/25.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZCComponentDrawLine : NSObject

/**
 *  画线起始点
 */
@property (nonatomic) CGPoint from_Point;
/**
 *  画线结束点
 */
@property (nonatomic) CGPoint to_Point;
/**
 *  画线颜色
 */
@property CGColorRef color;
/**
 *  画线宽度
 */
@property CGFloat width;


/**
 *  画线
 */
- (void)drawLine;


@end
