//
//  UCARTextFieldAssistant.m
//  Pods
//
//  Created by jiapeiqi on 2017/7/18.
//
//

#import "UCARTextFieldAssistant.h"

@interface UCARTextFieldAssistant()

@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, assign) BOOL isDeleteOperation;

@end

@implementation UCARTextFieldAssistant

+ (instancetype)textFieldCheckerWithMaxLength:(NSUInteger)maxLength divideLength:(NSUInteger)divideLength regexString:(NSString *)regexString
{
    UCARTextFieldAssistant *checker = [[UCARTextFieldAssistant alloc] init];
    checker.maxLength = maxLength;
    checker.divideLength = divideLength;
    [checker setRegexString:regexString];
    return checker;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxLength = 0;
        _divideLength = 0;
        _divideLenArray = nil;
        _separateLetter = @" ";
        _predicate = nil;
        _isDeleteOperation = NO;
    }
    return self;
}

- (void)setMaxLength:(NSUInteger)maxLength
{
    _maxLength = maxLength;
    [self checkLength];
}

- (void)setDivideLength:(NSUInteger)divideLength
{
    _divideLength = divideLength;
    [self checkLength];
}

- (void)checkLength
{
    //容错处理
    if (_maxLength > 0 && _divideLength > _maxLength) {
        _divideLength = 0;
    }
}

- (void)setRegexString:(NSString *)regexString
{
    if(regexString) {
        _predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
    } else {
        _predicate = nil;
    }
}

- (BOOL)textField:(UITextField *)textField couldChangeToNewText:(NSString *)newText newInputString:(NSString *)newInputString
{
    //    NSLog(@"---- newInputString %@", newInputString);
    
    _isDeleteOperation = newText.length < textField.text.length;
    
    //newText = nil，无法匹配正则，单独处理
    if (newText.length < 1) {
        return YES;
    }
    
    //首先进行正则验证
    //防止全选后输入长度变小误以为是删除
    if (_predicate) {
        NSString *cleanText = newText;
        if (_divideLength > 0 || _divideLenArray) {
            cleanText = [newText stringByReplacingOccurrencesOfString:_separateLetter withString:@""];
        }
        if (![_predicate evaluateWithObject:cleanText]) {
            NSLog(@"------ you wanna input somthing strange ? No way here!");
            return NO;
        }
    }
    
    //优先处理删除
    if (_isDeleteOperation) {
        return YES;
    }
    
    //浮点校验
    if (_integerLength > 0) {
        NSString *dot = @".";
        NSArray<NSString *> *numbers = [newText componentsSeparatedByString:dot];
        //整数
        if (numbers[0].length > _integerLength) {
            return NO;
        }
        //小数
        if (numbers.count > 1) {
            if (numbers[1].length > _decimalLength) {
                return NO;
            }
        }
        //非法浮点数
        if (textField.text.length > 0) {
            if ([[textField.text substringToIndex:1] isEqualToString:@"0"]) {
                if (![textField.text hasPrefix:@"0."]) {
                    if (![newInputString isEqualToString:@"."]) {
                        return NO;
                    }
                }
            }
        }
        if ([textField.text containsString:dot] || textField.text.length == 0) {
            if ([newInputString isEqualToString:dot]) {
                return NO;
            }
        }
    }
    
    if (_maxLength == 0) {
        return YES;
    }
    
    NSString *newCleanText = [newText stringByReplacingOccurrencesOfString:_separateLetter withString:@""];
    if (newCleanText.length > _maxLength) {
        return NO;
    }
    
    return YES;
}

- (NSString *)dividedStringFromString:(NSString *)string
{
    if (_divideLength > 0) {
        NSMutableArray *parts = [NSMutableArray array];
        for (NSInteger i=0; i<string.length; i=i+_divideLength)
        {
            NSString *subString = nil;
            if (i+_divideLength >= string.length) {
                NSInteger delta = string.length - i;
                subString = [string substringWithRange:NSMakeRange(i, delta)];
            } else {
                subString = [string substringWithRange:NSMakeRange(i, _divideLength)];
            }
            [parts addObject:subString];
        }
        //补入分隔符
        NSString *newString = [parts componentsJoinedByString:_separateLetter];
        return newString;
    }
    else if(_divideLenArray)
    {
        NSInteger index = 0;
        NSMutableArray *parts = [NSMutableArray array];
        for(NSInteger i = 0 ; i < _divideLenArray.count ; ++i)
        {
            NSInteger part = ((NSNumber *)_divideLenArray[i]).integerValue;
            if(string.length < index + part || part == 0)
                part = string.length - index;
            if(part <= 0)
                break;
            NSString *subString = [string substringWithRange:NSMakeRange(index, part)];
            [parts addObject:subString];
            index += part;
        }
        NSString *newString = [parts componentsJoinedByString:_separateLetter];
        return newString;
    }
    else
    {
        
        return string;
    }
}

- (NSString *)insertBeforeSeparateLetterToString:(NSString *)string
{
    NSString *cleanStr = [self cleanStringFromString:string];
    return [self dividedStringFromString:cleanStr];
}

- (NSString *)cleanStringFromString:(NSString *)string
{
    if (_divideLength > 0 || _divideLenArray) {
        NSString *cleanStr = [string stringByReplacingOccurrencesOfString:_separateLetter withString:@""];
        return cleanStr;
    } else {
        return string;
    }
}

@end
