//
//  ZCCommonCarFlagView.m
//  ZCBusiness
//
//  Created by ZhangYuqing on 2019/3/2.
//  Copyright © 2019 UCAR. All rights reserved.
//

// import分组次序：Frameworks、Services、UI
#import "ZCCommonCarFlagView.h"
#import <UIView+ZCComponent.h>
#import <Masonry/Masonry.h>

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ZCCommonCarFlagView ()
@property (strong,nonatomic) UIView *leftView;
@property (strong,nonatomic) UIView *rightView;
@property (strong,nonatomic) UILabel *leftLabel;
@property (strong,nonatomic) UILabel *rightLabel;
@end

@implementation ZCCommonCarFlagView


#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createCommonBaseUI];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)dealloc {
    NSLog(@"%@ - dealloc", NSStringFromClass([self class]));
}
    
- (void)createCommonBaseUI
{
    self.leftView = [[UIView alloc]init];
    [self addSubview:self.leftView];
    self.rightView = [[UIView alloc]init];
    [self addSubview:self.rightView];
    
    self.leftLabel = [[UILabel alloc]init];
    self.leftLabel.textColor = UIColorFromRGB(0xF12E49);
    self.leftLabel.font = [UIFont systemFontOfSize:10.0f];
    [self.leftLabel sizeToFit];
    [self.leftLabel setTextAlignment:NSTextAlignmentCenter];
    [self.leftView addSubview:self.leftLabel];
    [self.leftView createBordersWithColor:UIColorFromRGB(0xF12E49) withCornerRadius:4.0f andWidth:0.5f];
    
    self.rightLabel = [[UILabel alloc]init];
    self.rightLabel.textColor = UIColorFromRGB(0xF49C2F);
    self.rightLabel.font = [UIFont systemFontOfSize:10.0f];
    [self.rightLabel sizeToFit];
    [self.rightView addSubview:self.rightLabel];
    [self.rightLabel setTextAlignment:NSTextAlignmentCenter];
    [self.rightView createBordersWithColor:UIColorFromRGB(0xF49C2F) withCornerRadius:4.0f andWidth:0.5f];
    
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(5);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
        make.right.mas_equalTo(self.rightView.mas_left).offset(-5);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-5);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
        make.left.mas_equalTo(self.leftView.mas_right).offset(5);
    }];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(3,5,3,5));
    }];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.edges.mas_equalTo(UIEdgeInsetsMake(3,5, 3, 5));
    }];
}

- (void)setFlag1:(NSString *)flag1 flag2:(NSString *)flag2
{
    if (flag1.length > 0)
    {
        // 第一个是有值的
        self.leftLabel.text = flag1;
        self.leftView.hidden = NO;
        self.leftView.layer.borderColor = UIColorFromRGB(0xF12E49).CGColor;
        self.leftLabel.textColor = UIColorFromRGB(0xF12E49);
        if (flag2.length > 0)
        {
            // 第二个值有值
            self.rightLabel.text = flag2;
            self.rightView.hidden = NO;
            self.rightView.layer.borderColor = UIColorFromRGB(0xF49C2F).CGColor;
            self.rightLabel.textColor = UIColorFromRGB(0xF49C2F);
        }
        else
        {
            // 第二个是没值的情况
            self.rightLabel.text = @"";
            self.rightView.hidden = YES;
        }
    }
    else if (flag2.length > 0)
    {
        // 第一个值没有 但是第二个只有
        self.leftLabel.text = flag2;
        self.leftView.layer.borderColor = UIColorFromRGB(0xF49C2F).CGColor;
        self.leftLabel.textColor = UIColorFromRGB(0xF49C2F);
        self.leftView.hidden = NO;
        self.rightView.hidden = YES;
    }
    else
    {
        // 两个都没有值
        self.leftView.hidden = YES;
        self.rightView.hidden = YES;
    }
}

- (void)setLeftTextColor:(UIColor *)textColor cornerColor:(UIColor *)cornerColor
{
    self.leftLabel.textColor = textColor;
    self.leftView.layer.borderColor = cornerColor.CGColor;
}

- (void)setRightTextColor:(UIColor *)textColor cornerColor:(UIColor *)cornerColor
{
    self.rightLabel.textColor = textColor;
    self.rightView.layer.borderColor = cornerColor.CGColor;
}
@end
