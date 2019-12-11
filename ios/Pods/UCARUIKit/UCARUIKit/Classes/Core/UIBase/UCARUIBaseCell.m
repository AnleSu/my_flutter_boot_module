//
//   UCARUIBaseCell.m
//   UCARUIBaseDev
//
//   Created  by hong.zhu on 2018/12/4.
//   Copyright © 2018年 Arlen. All rights reserved.
//

#import "UCARUIBaseCell.h"

@implementation UCARUIBaseCell

// 返回cell
+ (instancetype)cellWithTableView:(UITableView*)tableView {
    // 以 class 名作为唯一标识
    NSString* ID = NSStringFromClass(self);
    // 返回
    return [self p_cellWithTableView:tableView ID:ID];
}

// 返回一个空白的cell
+ (id)blankCellWithTableView:(UITableView*)tableView {
    static NSString* const ID = @"UCARUIBaseCellID";
    // 返回
    return [self p_cellWithTableView:tableView ID:ID];
}

// init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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

#pragma mark -
#pragma mark - 私有方法
/** 返回一个空白的cell */
+ (id)p_cellWithTableView:(UITableView*)tableView ID:(NSString*)ID {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        // 注册 cell
        [tableView registerClass:self forCellReuseIdentifier:ID];
        // 重新获取
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
    }
    return cell;
}

@end
