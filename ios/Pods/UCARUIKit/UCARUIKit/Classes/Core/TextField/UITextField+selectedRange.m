//
//  UITextField+selectedRange.m
//  UCARPlatform
//
//  Created by jiapeiqi on 2017/6/27.
//  Copyright © 2017年 UCar. All rights reserved.
//

#import "UITextField+selectedRange.h"

@implementation UITextField (selectedRange)

- (NSRange)selectedRange {
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void)setSelectedRange:(NSRange)range {
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextPosition* startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition* endPosition = [self positionFromPosition:beginning offset:range.location + range.length];
    UITextRange* selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    
    [self setSelectedTextRange:selectionRange];
}

// 是否有选中的字符
- (BOOL)isHighLighted {
    UITextRange *selectedRange = [self markedTextRange];
    UITextPosition *pos = [self positionFromPosition:selectedRange.start offset:0];
    return (selectedRange && pos);
}

/** 输入无效时回到上一个光标状态 */
- (void)invalidTextFieldCurContent:(NSString*)curContent {
    // 保留光标的位置信息
    NSRange selectedRange = self.selectedRange;
    // 保留当前文本的内容
    NSString* tmpSTR = self.text;
    
    // 设置了文本,光标到了最后
    self.text = curContent;
    
    // 重新设置光标的位置
    selectedRange.location -= (tmpSTR.length - curContent.length);
    self.selectedRange = selectedRange;
}

@end
