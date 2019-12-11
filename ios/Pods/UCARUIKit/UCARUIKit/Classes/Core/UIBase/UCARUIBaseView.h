//
//   UCARUIBaseView.h
//   UCARUIBaseDev
//
//   Created  by hong.zhu on 2018/12/4.
//   Copyright © 2018年 Arlen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCARUIBaseView : UIView

/**
 添加子视图
 */
- (void)createSubViews;

/**
 布局子视图
 */
- (void)createSubViewsConstraints;

@end
