//
//  UCARTipView.h
//  UCar
//
//  Created by KouArlen on 15/8/19.
//  Copyright (c) 2015年 zuche. All rights reserved.
//

#import <UIKit/UIKit.h>

//don't call [self.view addSubview:view]

@interface UCARTipView : UIView

- (instancetype)initWithText:(NSString *)text containerView:(UIView *)containerView;
- (instancetype)initWithAttrText:(NSAttributedString *)text containerView:(UIView *)containerView;

- (instancetype)initWithImageName:(NSString *)imageName containerView:(UIView *)containerView;

- (instancetype)initWithImage:(UIImage *)image containerView:(UIView *)containerView;

- (void)show;

@end
