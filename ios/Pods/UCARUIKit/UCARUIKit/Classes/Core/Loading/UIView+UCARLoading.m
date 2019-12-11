//
//  UIView+UCARLoading.m
//  UCARUIKit
//
//  Created by North on 11/30/16.
//  Copyright © 2016 North. All rights reserved.
//

#import "UIView+UCARLoading.h"
#import "UCARLoadingViewProtocol.h"
#import <objc/runtime.h>
#import "UCARUIKitConfigInstance.h"

const CGFloat WhatLoadingViewWidth = 58.0;

@implementation UIView(UCARLoading)

static const char UCAR_loadingViewKey = '\0';
- (void)setUcar_loadingView:(UIView<UCARLoadingViewProtocol> *)ucar_loadingView
{
    if (ucar_loadingView != self.ucar_loadingView) {
        // 删除旧的，添加新的
        [self.ucar_loadingView removeFromSuperview];
        [self addSubview:ucar_loadingView];
        
        // 存储新的
        [self willChangeValueForKey:@"ucar_loadingView"]; // KVO
        objc_setAssociatedObject(self, &UCAR_loadingViewKey,
                                 ucar_loadingView, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"ucar_loadingView"]; // KVO
    }
}

- (UIView<UCARLoadingViewProtocol> *)ucar_loadingView
{
    return objc_getAssociatedObject(self, &UCAR_loadingViewKey);
}

- (UIView<UCARLoadingViewProtocol> *)generateLoadingView
{
    UIView<UCARLoadingViewProtocol> *loadingView = [[UCARUIKitConfigInstance sharedConfig].dataSource loadingView];
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    loadingView.center = center;
    
    return loadingView;
}

static const char UCAR_loadingBackViewKey = '\0';
- (void)setUcar_loadingBackView:(UIView *)ucar_loadingBackView
{
    if (ucar_loadingBackView != self.ucar_loadingBackView) {
        // 删除旧的，添加新的
        [self.ucar_loadingBackView removeFromSuperview];
        [self addSubview:ucar_loadingBackView];
        
        // 存储新的
        [self willChangeValueForKey:@"ucar_loadingBackView"]; // KVO
        objc_setAssociatedObject(self, &UCAR_loadingBackViewKey,
                                 ucar_loadingBackView, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"ucar_loadingBackView"]; // KVO
    }
}

- (UIView *)ucar_loadingBackView
{
    return objc_getAssociatedObject(self, &UCAR_loadingBackViewKey);
}

- (void)showLoading
{
    if (!self.ucar_loadingView.isAnimating) {
        [self dismissLoading];
    }
    if (self.ucar_loadingBackView) {
        self.ucar_loadingBackView.hidden = YES;
    }
    if (!self.ucar_loadingView) {
        self.ucar_loadingView = [self generateLoadingView];
    }
    [self bringSubviewToFront:self.ucar_loadingView];
    self.ucar_loadingView.hidden = NO;
    [self.ucar_loadingView startAnimating];
}

- (void)showLoadingClear
{
    [self showLoadingClearWithOffsetY:0.0];
}

- (void)showLoadingClearInController
{
    [self showLoadingClearWithOffsetY:64.0];
}

- (void)showLoadingClearWithOffsetY:(CGFloat)offsetY
{
    //勿改变loading与back的设置顺序
    [self showLoading];
    if (!self.ucar_loadingBackView) {
        UIView *backView = [[UIView alloc] initWithFrame:self.bounds];
        self.ucar_loadingBackView = backView;
    }
    CGSize size = self.bounds.size;
    self.ucar_loadingBackView.frame = CGRectMake(0, offsetY, size.width, size.height-offsetY);
    [self bringSubviewToFront:self.ucar_loadingBackView];
    self.ucar_loadingBackView.hidden = NO;
    
}

- (void)dismissLoading
{
    if (self.ucar_loadingBackView) {
        self.ucar_loadingBackView.hidden = YES;
    }
    if (self.ucar_loadingView) {
        [self.ucar_loadingView stopAnimating];
    }
}

@end
