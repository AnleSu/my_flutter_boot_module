//
//  UCARUIKitConfig.m
//  UCARUIKit
//
//  Created by linux on 28/02/2018.
//

#import "UCARUIKitConfig.h"

@implementation UCARUIKitConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initConfig];
    }
    return self;
}

- (void)initConfig
{
}

@end

@implementation UCARToastViewConfig

- (void)initConfig
{
    [super initConfig];
    
    _backgroundColor = [UIColor grayColor];
    _titleColor = [UIColor whiteColor];
    _titleFont = [UIFont systemFontOfSize:14];
    
    _cornerRadius = 0;
    _minWidth = 90;
    _maxWidth = 210;
    _padding = 15;
    _iconSize = 36;
    
    _infoImage = nil;
    _successImage = nil;
    _failImage = nil;
}

@end

@implementation UCARAlertViewConfig

- (void)initConfig
{
    [super initConfig];
    
    _buttonLayoutStyle = UCARAlertButtonLayoutStyleHammer;
    
    _isTitleMustCenter = NO;
    _isMessageMustCenter = NO;
    
    _margin = 53;
    _padding = 20;
    
    _titleColor = [UIColor blackColor];
    _titleFont = [UIFont systemFontOfSize:20];
    
    _noMessageTitleFont = [UIFont systemFontOfSize:16];
    
    _messageColor = [UIColor blackColor];
    _messageFont = [UIFont systemFontOfSize:14];
}

@end
