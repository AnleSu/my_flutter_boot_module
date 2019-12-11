//
//  ZCOneButtonBottomView.m
//  ZCBusiness
//
//  Created by 曹志勇 on 2019/2/18.
//  Copyright © 2019 UCAR. All rights reserved.
//

// import分组次序：Frameworks、Services、UI
#import "ZCOneButtonBottomView.h"
#import <Masonry/Masonry.h>

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ZCOneButtonBottomView ()

@property (nonatomic, readwrite, strong) UIButton *bottomButton;

@end

@implementation ZCOneButtonBottomView


#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubViews];
        [self createSubViewsConstraints];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)dealloc {
    NSLog(@"%@ - dealloc", NSStringFromClass([self class]));
}

#pragma mark - Events

- (void)onclickBtn {
    
    if (self.clickBottomBtn) {
        self.clickBottomBtn([self.bottomButton titleForState:UIControlStateNormal]);
    }
}

#pragma mark - Private Methods

// 添加子视图
- (void)createSubViews {
    
    [self addSubview:self.bottomButton];
}

// 添加约束
- (void)createSubViewsConstraints {
    
    [self.bottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark - Getters and Setters

- (void)setButtonTitle:(NSString *)buttonTitle {
    _buttonTitle = buttonTitle;
    [self.bottomButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (UIButton *)bottomButton {
    if (!_bottomButton) {
        _bottomButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _bottomButton.titleLabel.font = [UIFont systemFontOfSize:17.f];
        [_bottomButton setBackgroundImage:[self zc_imageWithColor:UIColorFromRGB(0xBCBCBC)] forState:UIControlStateDisabled];
        [_bottomButton setBackgroundImage:[self zc_imageWithColor:UIColorFromRGB(0xF12E49)] forState:UIControlStateNormal];
        [_bottomButton setBackgroundImage:[self zc_imageWithColor:UIColorFromRGB(0xBC0C24)] forState:UIControlStateHighlighted];
//        _bottomButton.enabled = NO;
        [_bottomButton addTarget:self action:@selector(onclickBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomButton;
}


//通过过color绘制图片
-  (UIImage *)zc_imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
