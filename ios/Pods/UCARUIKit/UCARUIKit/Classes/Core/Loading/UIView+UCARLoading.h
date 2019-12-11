//
//  UIView+UCARLoading.h
//  UCARUIKit
//
//  Created by North on 11/30/16.
//  Copyright © 2016 North. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(UCARLoading)

- (void)showLoading;
- (void)showLoadingClear;
//不可点击区域会向下偏移64点
- (void)showLoadingClearInController;

- (void)dismissLoading;

@end
