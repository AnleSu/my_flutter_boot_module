//
//  UCARDragView.h
//  UCARDragTest-03-16
//
//  Created by 闫子阳 on 2018/3/16.
//  Copyright © 2018年 闫子阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCARDragViewConfig.h"

@class UCARDragView;

@protocol UCARDragViewDelegate <NSObject>

@required
- (NSInteger)dragView:(UCARDragView *)dragView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)dragView:(UCARDragView *)dragView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)dragView:(UCARDragView *)dragView startPan:(UIPanGestureRecognizer *)recognizer;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (void)dragView:(UCARDragView *)dragView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)dragViewWillBeginDragging:(UCARDragView *)dragView;
- (void)dragViewDidScroll:(UCARDragView *)dragView;
- (void)dragView:(UCARDragView *)dragView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)dragView:(UCARDragView *)dragView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray<UITableViewRowAction *> *)dragView:(UCARDragView *)dragView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath;

// ios11之后支持此方法
//- (UISwipeActionsConfiguration *)dragView:(UCARDragView *)dragView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath;


@end

@interface UCARDragView : UIView

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *pan;
@property (nonatomic, weak) id<UCARDragViewDelegate> delegate;

- (instancetype)initWithConfig:(UCARDragViewConfig *)config;
+ (instancetype)dragViewWithConfig:(UCARDragViewConfig *)config;

@end
