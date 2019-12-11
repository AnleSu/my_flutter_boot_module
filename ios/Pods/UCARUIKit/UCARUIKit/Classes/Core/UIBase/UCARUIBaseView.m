//
//   UCARUIBaseView.m
//   UCARUIBaseDev
//
//   Created  by hong.zhu on 2018/12/4.
//   Copyright © 2018年 Arlen. All rights reserved.
//

#import "UCARUIBaseView.h"

@implementation UCARUIBaseView

// init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 添加子视图
        [self createSubViews];
        // 布局子视图
        [self createSubViewsConstraints];
    }
    return self;
}

// 添加子视图
- (void)createSubViews {
    // TODO: 子类实现 添加子视图
}

// 布局子视图
- (void)createSubViewsConstraints {
    // TODO: 子类实现 布局子视图
}

@end
