//
//  UITextField+selectedRange.h
//  UCARPlatform
//
//  Created by jiapeiqi on 2017/6/27.
//  Copyright © 2017年 UCar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (selectedRange)

/** 当前控件的选定区域
 @note 主要处理光标
 */
@property (nonatomic, assign) NSRange selectedRange;

/** 是否有选中的字符 */
@property (nonatomic, assign, readonly) BOOL isHighLighted;

/**
 输入无效时回到上一个光标状态
 @note 主要是为了处理光标的位置
 @param curContent 希望当前的显示内容
 */
- (void)invalidTextFieldCurContent:(NSString*)curContent;

@end
