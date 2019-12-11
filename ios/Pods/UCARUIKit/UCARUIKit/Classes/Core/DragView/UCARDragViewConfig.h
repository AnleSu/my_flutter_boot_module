//
//  UCARDragViewConfig.h
//  UCARDragTest-03-16
//
//  Created by 闫子阳 on 2018/3/22.
//  Copyright © 2018年 闫子阳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UCARDragView;

@interface UCARDragViewConfig : NSObject

@property (nonatomic, strong) UIView *header;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) UIEdgeInsets headerInsets;
@property (nonatomic, assign) CGFloat minTop;
@property (nonatomic, assign) CGFloat maxTop;

@end
