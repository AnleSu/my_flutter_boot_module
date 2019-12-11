//
//  UCARTextFieldAssistant.h
//  Pods
//
//  Created by jiapeiqi on 2017/7/18.
//
//

#import <Foundation/Foundation.h>

@interface UCARTextFieldAssistant : NSObject

//浮点数校验
//整数长度, default = 0
@property (nonatomic, assign) NSUInteger integerLength;
//小数长度
@property (nonatomic, assign) NSUInteger decimalLength;

//浮点校验功能与divide功能互斥

//可输入的最大长度, default = 0, 无限制
@property (nonatomic, assign) NSUInteger maxLength;
//等分分隔长度，固定长度自动插入空格, default = 0, 不分隔。《注意：与divideLenArray互斥》。default is 0 不分割.
@property (nonatomic, assign) NSUInteger divideLength;
//分隔符 default is blank space @" "
@property (nonatomic, strong) NSString *separateLetter;
//字符串非等分的分割。《注意：与divideLength互斥》。default is nil。
//最后一段不限制长度，可将最后数组一个元素设置为0.
@property (nonatomic, strong) NSArray *divideLenArray;


+ (instancetype)textFieldCheckerWithMaxLength:(NSUInteger)maxLength divideLength:(NSUInteger)divideLength regexString:(NSString *)regexString;

//设置正则表达式, default = nil, 无正则限制
//if you want to remove current reg, set this nil
- (void)setRegexString:(NSString *)regexString;

- (BOOL)textField:(UITextField *)textField couldChangeToNewText:(NSString *)newText newInputString:(NSString *)newInputString;

/*
 get a string divided using blank according to divideLength
 you must set property "divideLength" before calling this function
 */
- (NSString *)dividedStringFromString:(NSString *)string;

/*
 clean the blank characters
 */
- (NSString *)cleanStringFromString:(NSString *)string;
/*
 first cleanString ,then insert blan characters.need set divideLength
 */
- (NSString *)insertBeforeSeparateLetterToString:(NSString *)string;

@end
