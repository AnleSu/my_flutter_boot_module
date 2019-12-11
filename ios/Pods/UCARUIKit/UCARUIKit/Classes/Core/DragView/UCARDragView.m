//
//  UCARDragView.m
//  UCARDragTest-03-16
//
//  Created by 闫子阳 on 2018/3/16.
//  Copyright © 2018年 闫子阳. All rights reserved.
//

#import "UCARDragView.h"
#import <UCARUIkit/UIViewExt.h>

@interface UCARDragView () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, assign) CGFloat currentY;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) CGFloat ty;
@property (nonatomic, assign) CGPoint speed;
@property (nonatomic, assign) BOOL isInit;
@property (nonatomic, assign) BOOL isHold;

@property (nonatomic, strong) UCARDragViewConfig *config;

@end

@implementation UCARDragView

- (UIPanGestureRecognizer *)pan
{
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        _pan.delegate = self;
    }
    return _pan;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = 50;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (instancetype)initWithConfig:(UCARDragViewConfig *)config
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        
        _config = config;
        _isInit = YES;
        _currentY = self.config.minTop;
        
        [self addSubview:config.header];
        [self addSubview:self.tableView];
        
        [self addGestureRecognizer:self.pan];
    }
    return self;
}

+ (instancetype)dragViewWithConfig:(UCARDragViewConfig *)config
{
    return [[self alloc] initWithConfig:config];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.config.header.left = self.config.headerInsets.left;
    self.config.header.top = self.config.headerInsets.top;
    self.config.header.width = self.width - self.config.headerInsets.left - self.config.headerInsets.right;
    self.config.header.height = self.config.headerHeight - self.config.headerInsets.top - self.config.headerInsets.bottom;
    
    self.tableView.left = 0;
    self.tableView.top = CGRectGetMaxY(self.config.header.frame) + self.config.headerInsets.bottom;
    self.tableView.width = self.width;
    self.tableView.height = self.height - self.config.headerHeight;
}

- (void)panAction:(UIPanGestureRecognizer *)recognizer
{
    if (!recognizer.enabled) {
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        self.tableView.scrollEnabled = YES;
        self.tableView.showsVerticalScrollIndicator = YES;
        if (self.top <= (self.config.maxTop + self.config.minTop) * 0.5 || self.speed.y < -500) { //向上滑
            [UIView animateWithDuration:0.2 animations:^{
                self.top = self.config.minTop;
            }completion:^(BOOL finished) {
                self.currentY = self.config.minTop;
                
            }];
        }
        
        if (self.top > (self.config.maxTop + self.config.minTop) * 0.5 || self.speed.y > 500) { //向下滑
            self.isInit = YES;
            [UIView animateWithDuration:0.2 animations:^{
                self.top = self.config.maxTop;
            }completion:^(BOOL finished) {
                self.currentY = self.config.maxTop;
            }];
        }
    } else {
        // 在y方向移动
        self.tableView.showsVerticalScrollIndicator = NO;
        self.ty = [recognizer translationInView:self].y;
//        if (self.ty > 0) { // 向下滑
//            self.isInit = YES;
//        }
        self.speed = [recognizer velocityInView:self];
        [recognizer setTranslation:CGPointZero inView:self];
        self.top += self.ty;
        
        if (self.top < self.config.minTop) {
            self.top = self.config.minTop;
        } else if (self.top > self.config.maxTop) {
            self.top = self.config.maxTop;
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    self.pan.enabled = YES;
    UIView *view = [super hitTest:point withEvent:event];
    CGRect headerRect = CGRectMake(0, 0, self.width, self.config.headerHeight);
    BOOL isInHead = CGRectContainsPoint(headerRect, point);
    if (self.tableView.contentOffset.y != 0 && self.top == self.config.minTop && !isInHead) {
        self.pan.enabled = NO;
    }
    
    return view;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.top == self.config.minTop || self.top == self.config.maxTop) {
        return YES;
    }

    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.delegate respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        return [self.delegate numberOfSectionsInTableView:tableView];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.delegate dragView:self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate dragView:self cellForRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dragView:didSelectRowAtIndexPath:)]) {
        [self.delegate dragView:self didSelectRowAtIndexPath:indexPath];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isHold = NO;
    
    if ([self.delegate respondsToSelector:@selector(dragViewDidScroll:)]) {
        [self.delegate dragViewDidScroll:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"self.y = %f, self.pan.enabled = %d", self.top, self.pan.enabled);
    
    if (self.top == self.config.minTop) { // 展开时，可以向上拖动table
        if ((self.offsetY == 0 && scrollView.contentOffset.y <= 0) || self.isHold) { // table滑到top && 向下滑
            scrollView.contentOffset = CGPointMake(0, self.offsetY);
        } else {
            self.isInit = NO;
        }
    } else if (self.top == self.config.maxTop) {
        if (scrollView.contentOffset.y > self.offsetY) { // 向上滑
            scrollView.contentOffset = CGPointMake(0, self.offsetY);
            scrollView.scrollEnabled = NO;
        } else {
            if (scrollView.contentOffset.y <= 0) {
                scrollView.contentOffset = CGPointMake(0, 0);
            }
        }
    } else {
        if (self.isInit) {
            scrollView.contentOffset = CGPointMake(0, self.offsetY);
            self.isHold = YES;
        } else {
            self.top = self.config.minTop;
//            NSLog(@"%f", scrollView.contentOffset.y);
            if (scrollView.contentOffset.y <= 0) {
                self.isInit = YES;
                scrollView.contentOffset = CGPointMake(0, 0);
            }
        }
    }

    self.offsetY = scrollView.contentOffset.y;
    if (self.offsetY <= 0) {
        self.offsetY = 0;
    }
    
    if ([self.delegate respondsToSelector:@selector(dragView:startPan:)]) {
        [self.delegate dragView:self startPan:self.pan];
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dragView:willBeginEditingRowAtIndexPath:)]) {
        [self.delegate dragView:self willBeginEditingRowAtIndexPath:indexPath];
    }
}

//- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self.delegate respondsToSelector:@selector(dragView:trailingSwipeActionsConfigurationForRowAtIndexPath:)]) {
//        self.pan.enabled = NO;
//        return [self.delegate dragView:self trailingSwipeActionsConfigurationForRowAtIndexPath:indexPath];
//    }
//
//    return nil;
//}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dragView:editActionsForRowAtIndexPath:)]) {
        self.pan.enabled = NO;
        return [self.delegate dragView:self editActionsForRowAtIndexPath:indexPath];
    }

    return @[];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dragView:didEndEditingRowAtIndexPath:)]) {
        [self.delegate dragView:self didEndEditingRowAtIndexPath:indexPath];
    }
}

- (void)dealloc
{
    [self removeGestureRecognizer:_pan];
}

@end
