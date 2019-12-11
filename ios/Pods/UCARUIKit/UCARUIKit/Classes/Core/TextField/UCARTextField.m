//
//  UCARTextField.m
//  UCARPlatform
//
//  Created by jiapeiqi on 2017/7/14.
//  Copyright © 2017年 UCar. All rights reserved.
//

#import "UCARTextField.h"
#import "UCARTextFieldAssistant.h"
#import "UCARNumberKeyBoard.h"
#import "UITextField+selectedRange.h"


@interface UCARTextField()<UITextFieldDelegate>

@property(nonatomic,strong)UCARTextFieldAssistant *checker;
@property(nonatomic,strong)UCARNumberKeyBoard *customKeyboard;
@property(nonatomic,strong)NSString *DoneButtonString;

@end

@implementation UCARTextField

-(instancetype)initWithRegexString:(NSString *)regexString
{
    self = [super init];
    if(self)
    {
        self.delegate = self;
        _separateChar = @" ";
        _maxLength = 0;
        _divideLength = 0;
        _regexString = regexString;
        _DoneButtonInput = NO;
        _DoneButtonString = @"";
        _checker = [UCARTextFieldAssistant textFieldCheckerWithMaxLength:0 divideLength:0 regexString:regexString];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setRegexString:(NSString *)regexString
{
    _regexString = regexString;
    [_checker setRegexString:regexString];
}

- (void)setIntegerLength:(NSUInteger)integerLength
{
    _integerLength = integerLength;
    _checker.integerLength = integerLength;
}

- (void)setDecimalLength:(NSUInteger)decimalLength
{
    _decimalLength = decimalLength;
    _checker.decimalLength = decimalLength;
}

-(void)setMaxLength:(NSInteger)maxLength
{
    _maxLength = maxLength;
    _checker.maxLength = maxLength;
}

-(void)setDivideLength:(NSInteger)divideLength
{
    _divideLength = divideLength;
    _checker.divideLength = divideLength;
}

-(void)setDivideLenArray:(NSArray *)divideLenArray
{
    _divideLenArray = divideLenArray;
    _checker.divideLenArray = divideLenArray;
}

-(void)setSeparateChar:(NSString*)separateChar
{
    if(separateChar)
    {
        _separateChar = separateChar;
        _checker.separateLetter = separateChar;
    }
}

-(void)useCustomNumberKeyboardWithButtonName:(NSString *)name
{
    self.DoneButtonString = name;
    self.customKeyboard = [UCARNumberKeyBoard keyBoardWithTitle:name];
    __weak UCARTextField *weakSelf = self;
    _customKeyboard.clickBlock = ^(NSString *input, UCARNumberKeyBoardClickType clickType, NSInteger inputTag){
        [weakSelf numberKeyBoardClicked:clickType input:input];
    };
    
    self.inputView = _customKeyboard;

}

- (void)textDidChange:(NSNotification *)notifiaction
{
    if(![notifiaction.object isKindOfClass:[self class]])
        return;
    UITextRange *selectedRange = [self markedTextRange];
    if (selectedRange) {
        return;
    }
    NSString *oriStr = [NSString stringWithString:self.text];
    NSString *clearStr = [_checker cleanStringFromString:self.text];
    NSRange selectRange = self.selectedRange;
    if(_maxLength > 0 && clearStr.length>_maxLength)
    {
        self.text = [clearStr substringToIndex:_maxLength];
        selectRange.location = _maxLength;
    }
    self.text = [_checker insertBeforeSeparateLetterToString:self.text];
    if(selectRange.location + 1 == self.text.length && (_divideLength > 0 || _divideLenArray) && [[self.text substringFromIndex:self.text.length-1] isEqualToString:_separateChar])
    {
        [self setSelectedRange:NSMakeRange(selectRange.location + 1, 0)];
    }
    else
    {
        NSUInteger finalLoc = [self findFinalCursorLocationWithOraginString:oriStr newString:self.text oriLocation:selectRange.location];
        [self setSelectedRange:NSMakeRange(finalLoc, 0)];
    }
    if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldDidChange:)])
    {
        [self.textFieldDelegate textFieldDidChange:self];
    }

}

- (NSUInteger)findFinalCursorLocationWithOraginString:(const NSString *)oriStr newString:(const NSString *)newString oriLocation:(NSUInteger)oriLoc
{
    if(oriLoc > newString.length) return newString.length;
    NSString *leftStr = [_checker cleanStringFromString:[oriStr substringToIndex:oriLoc]];
    NSUInteger finalLoc = oriLoc;
    for(NSUInteger i = oriLoc ; i <= newString.length ; ++i)
    {
        if([leftStr isEqualToString:[_checker cleanStringFromString:[newString substringToIndex:i]]])
        {
            finalLoc = i;
            break;
        }
    }
    return finalLoc;
    
}

#pragma mark - keyboard
- (void)numberKeyBoardClicked:(UCARNumberKeyBoardClickType)clickType input:(NSString *)input
{
    switch (clickType) {
        case UCARNumberKeyBoardClickTypeInput:
            [self inputText:input];
            break;
        case UCARNumberKeyBoardClickTypeUserDefined:
            [self inputDone];
            break;
        case UCARNumberKeyBoardClickTypeDelete:
            [self deleteText];
            break;
        default:
            break;
    }
}

- (void)inputText:(NSString *)input
{
    NSRange selectedRange = self.selectedRange;
    NSString *newText = [self.text stringByReplacingCharactersInRange:selectedRange withString:input];
    if ([_checker textField:self couldChangeToNewText:newText newInputString:input]) {
        BOOL onEnd = selectedRange.location == self.text.length ? YES : NO;
        self.text = [self.text stringByReplacingCharactersInRange:selectedRange withString:input];
        self.text = [_checker insertBeforeSeparateLetterToString:self.text];
        if(!onEnd)
        {
            if((_divideLength > 0 || _divideLenArray) && [_separateChar isEqualToString:[self.text substringWithRange:NSMakeRange(selectedRange.location, 1)]])
            {
                [self setSelectedRange:NSMakeRange(selectedRange.location + 2, 0)];
            }
            else
            {
                [self setSelectedRange:NSMakeRange(selectedRange.location + 1, 0)];
            }
        }

        if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldDidChange:)])
        {
            [self.textFieldDelegate textFieldDidChange:self];
        }
    }
}

- (void)deleteText
{
    NSRange selectedRange = self.selectedRange;
    NSString *leftStr = [self.text substringToIndex:selectedRange.location];
    NSString *rightStr = [self.text substringFromIndex:selectedRange.location];
    if(selectedRange.length>0)
    {
        rightStr = [rightStr substringFromIndex:selectedRange.length];
    }
    else
    {
        if(leftStr.length>0)
        {
            if(leftStr.length > 1 && [_separateChar isEqualToString:[leftStr substringFromIndex:leftStr.length - 1]])
            {
                leftStr = [leftStr substringToIndex:leftStr.length-2];
            }
            else
            {
                leftStr = [leftStr substringToIndex:leftStr.length-1];
            }
        }
    }
    NSString *deletedStr = [leftStr stringByAppendingString:rightStr];
    self.text = [_checker insertBeforeSeparateLetterToString:deletedStr];
    NSUInteger finalCursor = leftStr.length <= self.text.length ? leftStr.length : self.text.length;
    [self setSelectedRange:NSMakeRange(finalCursor, 0)];
    if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldDidChange:)])
    {
        [self.textFieldDelegate textFieldDidChange:self];
    }

}

- (void)inputDone
{
    if(_DoneButtonInput)
    {
        [self inputText:self.DoneButtonString];
    }
    else
    {
        [self resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
    {
        return [self.textFieldDelegate textFieldShouldBeginEditing:self];
    }
    else
    {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
    {
        return [self.textFieldDelegate textFieldDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
    {
        return [self.textFieldDelegate textFieldShouldEndEditing:self];
    }
    else
    {
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:)])
    {
        return [self.textFieldDelegate textFieldDidEndEditing:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(_regexString)
    {
        NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _regexString];
        if (![string isEqualToString:@""] && ![numberPre evaluateWithObject:string])
        {
            return NO;
        }
    }
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(_maxLength > 0 && [_checker cleanStringFromString:newText].length>_maxLength)
        return NO;
    
    if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
    {
        return [self.textFieldDelegate textField:self shouldChangeCharactersInRange:range replacementString:string];
    }
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldShouldClear:)])
    {
        return [self.textFieldDelegate textFieldShouldClear:self];
    }
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldShouldReturn:)])
    {
        return [self.textFieldDelegate textFieldShouldReturn:self];
    }
    else
    {
        return YES;
    }
}

@end
