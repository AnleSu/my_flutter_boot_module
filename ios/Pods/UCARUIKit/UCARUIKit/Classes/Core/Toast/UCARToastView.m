//
//  UCARToastView.m
//  UCar
//
//  Created by KouArlen on 16/3/18.
//  Copyright © 2016年 zuche. All rights reserved.
//

#import "UCARToastView.h"
#import "UCARUIKitTools.h"
#import "UCARUIKitConfigInstance.h"

@interface UCARToastView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong, nonnull) UIColor *titleColor;
@property (nonatomic, strong, nonnull) UIFont *titleFont;

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGFloat iconSize;

@property (nonatomic, strong, nullable) UIImage *infoImage;
@property (nonatomic, strong, nullable) UIImage *successImage;
@property (nonatomic, strong, nullable) UIImage *failImage;

@end

@implementation UCARToastView

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = self.cornerRadius;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UCARToastViewConfig *config = [UCARUIKitConfigInstance sharedConfig].toastViewConfig;
        self.backgroundColor = config.backgroundColor;
        self.titleColor = config.titleColor;
        self.titleFont = config.titleFont;
        
        self.cornerRadius = config.cornerRadius;
        self.minWidth = config.minWidth;
        self.maxWidth = config.maxWidth;
        self.padding = config.padding;
        self.iconSize = config.iconSize;
        
        self.infoImage = config.infoImage;
        self.successImage = config.successImage;
        self.failImage = config.failImage;
        
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)setText:(NSString *)text iconType:(UCARToastIconType)iconType;
{
    if (!text) {
        self.titleLabel.attributedText = nil;
        return;
    }
    
    CGFloat titleWidth = self.maxWidth-self.padding*2;
    CGSize constraintSize = CGSizeMake(titleWidth, 2000);
    NSDictionary *textDict = @{NSFontAttributeName: self.titleFont, NSForegroundColorAttributeName: self.titleColor};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:textDict];
    self.titleLabel.attributedText = attrStr;
    
    CGSize titleSize = [attrStr boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    if (titleSize.width < titleWidth) {
        titleWidth = titleSize.width;
    }
    
    CGFloat viewWidth = titleWidth + self.padding * 2;
    if (viewWidth < self.minWidth) {
        viewWidth = self.minWidth;
    }
    
    CGFloat viewHeight = titleSize.height + self.padding*2;
    
    UIImage *image = nil;
    switch (iconType) {
        case UCARToastIconTypeInfo:
            image = self.infoImage;
            break;
        case UCARToastIconTypeSuccess:
            image = self.successImage;
            break;
        case UCARToastIconTypeFail:
            image = self.failImage;
            break;
        default:
            break;
    }
    
    if (image) {
        self.imageView.image = image;
        self.imageView.frame = CGRectMake((viewWidth-self.iconSize)/2, self.padding, self.iconSize, self.iconSize);
        self.titleLabel.frame = CGRectMake((viewWidth-titleWidth)/2, self.padding*2+self.iconSize, titleWidth, titleSize.height);
        viewHeight += self.padding + self.iconSize;
    } else {
        self.imageView.image = nil;
        self.titleLabel.frame = CGRectMake((viewWidth-titleWidth)/2, self.padding, titleWidth, titleSize.height);
    }
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake((screenSize.width-viewWidth)/2, (screenSize.height-viewHeight)/2, viewWidth, viewHeight);
}

@end
