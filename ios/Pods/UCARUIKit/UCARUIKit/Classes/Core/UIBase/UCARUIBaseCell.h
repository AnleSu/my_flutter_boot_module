//
//   UCARUIBaseCell.h
//   UCARUIBaseDev
//
//   Created  by hong.zhu on 2018/12/4.
//   Copyright © 2018年 Arlen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCARUIBaseCell : UITableViewCell

/**
 返回一个Cell实例, 通常用于纯代码编写的子类
 
 @param tableView 当前表视图视图
 @return 返回Cell
 */
+ (instancetype)cellWithTableView:(UITableView*)tableView;

/**
 返回一个空白Cell, 主要用于占位Cell
 
 @param tableView 当前表视图视图
 @return 返回Cell
 */
+ (id)blankCellWithTableView:(UITableView*)tableView;

/**
 添加子视图
 */
- (void)createSubViews;

/**
 布局子视图
 */
- (void)createSubViewsConstraints;

@end
