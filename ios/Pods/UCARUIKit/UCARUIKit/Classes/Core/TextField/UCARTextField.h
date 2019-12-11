//
//  UCARTextField.h
//  UCARPlatform
//
//  Created by jiapeiqi on 2017/7/14.
//  Copyright © 2017年 UCar. All rights reserved.
//

#import <UIKit/UIKit.h>


@class UCARTextField;

@protocol UCARTextFieldDelegate <NSObject>

@optional

// return NO to disallow editing.
- (BOOL)textFieldShouldBeginEditing:(UCARTextField *)textField;

// became first responder
- (void)textFieldDidBeginEditing:(UCARTextField *)textField;

// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (BOOL)textFieldShouldEndEditing:(UCARTextField *)textField;

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UCARTextField *)textField;

// return NO to not change text
- (BOOL)textField:(UCARTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

// called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldClear:(UCARTextField *)textField;

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UCARTextField *)textField;

// 字符串有变化
- (void)textFieldDidChange:(UCARTextField *)textField;//包含粘贴导致字符串变化


@end


@interface UCARTextField : UITextField

@property (nonatomic, weak) id<UCARTextFieldDelegate> textFieldDelegate;

//浮点数校验
//整数长度, default = 0
@property (nonatomic, assign) NSUInteger integerLength;
//小数长度
@property (nonatomic, assign) NSUInteger decimalLength;

//浮点校验功能与divide功能互斥

@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, strong) NSString *separateChar;
@property (nonatomic, strong) NSString *regexString;
//等分分隔长度，固定长度自动插入空格, default = 0, 不分隔。《注意：与divideLenArray互斥》。default is 0 不分割.
@property (nonatomic, assign) NSInteger divideLength;
//字符串非等分的分割。《注意：与divideLength互斥》。default is nil。
//最后一段不限制长度，可将最后数组一个元素设置为0.
@property (nonatomic, strong) NSArray *divideLenArray;

@property (nonatomic, assign) BOOL DoneButtonInput;//右下角按钮作为普通输入，例如身份证号


- (instancetype)initWithRegexString:(NSString *)regexString;//must init with this method

- (void)useCustomNumberKeyboardWithButtonName:(NSString *)name;


@end
