//
//  UCARTipView.m
//  UCar
//
//  Created by KouArlen on 15/8/19.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import "UCARTipView.h"
#import "UCARUIKitTools.h"

@interface UCARTipView()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIImageView *tipImageView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, weak)   UIView *containerView;
@end

@implementation UCARTipView

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.numberOfLines = 0;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        _tipLabel.userInteractionEnabled = YES;
        [_tipLabel addGestureRecognizer:gesture];
    }
    return _tipLabel;
}

- (UIImageView *)tipImageView
{
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        _tipImageView.userInteractionEnabled = YES;
        _tipImageView.backgroundColor = [UIColor clearColor];
        _tipImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_tipImageView addGestureRecognizer:gesture];

    }
    return _tipImageView;
}

- (UIView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _backgroundView;
}

- (instancetype)initWithText:(NSString *)text containerView:(UIView *)containerView
{
        
    NSAttributedString *textAttr = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0], NSForegroundColorAttributeName: UCAR_ColorFromHexString(@"343434")}];
    return [self initWithAttrText:textAttr containerView:containerView];
}

- (instancetype)initWithAttrText:(NSAttributedString *)attrText containerView:(UIView *)containerView
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _containerView = containerView;
        
        CGFloat viewWidth = 281 * UCAR_ViewZoomRatio();
        CGFloat topPadding = 20;
        CGFloat leftPadding = 14 * UCAR_ViewZoomRatio();
        CGFloat labelWidth = viewWidth-leftPadding*2;
        
        CGFloat textHeight = [attrText boundingRectWithSize:CGSizeMake(labelWidth, 2000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        self.tipLabel.frame = CGRectMake(leftPadding, topPadding, labelWidth, textHeight);
        self.tipLabel.attributedText = attrText;
        [self addSubview:self.tipLabel];
        
        self.frame = CGRectMake(0, 0, viewWidth, textHeight+topPadding*2);
        
        [self setupSelf];
    }
    return self;
}

- (instancetype)initWithImageName:(NSString *)imageName containerView:(UIView *)containerView
{
    UIImage *image = [UIImage imageNamed:imageName];
    return [self initWithImage:image containerView:containerView];
}

- (instancetype)initWithImage:(UIImage *)image containerView:(UIView *)containerView
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _containerView = containerView;
        
        CGSize imageSize = CGSizeMake(image.size.width*UCAR_ViewZoomRatio(), image.size.height*UCAR_ViewZoomRatio());
        self.tipImageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        self.tipImageView.image = image;
        [self addSubview:self.tipImageView];
        
        self.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        
        [self setupSelf];
    }
    return self;
    
}


- (void)setupSelf
{
    CGFloat width = self.containerView.bounds.size.width;
    CGFloat height = self.containerView.bounds.size.height;
    self.center = CGPointMake(width/2, height/2);
    self.layer.cornerRadius = 2.0;
    self.alpha = 0.0;
    self.backgroundView.frame = self.containerView.bounds;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self.backgroundView addGestureRecognizer:gesture];
}

- (void)show
{
    [_containerView addSubview:self.backgroundView];
    [_containerView addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

@end
