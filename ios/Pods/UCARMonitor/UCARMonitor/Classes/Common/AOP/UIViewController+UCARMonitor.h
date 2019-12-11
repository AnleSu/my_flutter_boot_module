//
//  UIViewController+UCARMonitor.h
//  UCARMonitor
//
//  Created by linux on 2018/7/11.
//

#import <UIKit/UIKit.h>

/**
 UIViewController扩展，用于monitor统计vc事件
 */
@interface UIViewController (UCARMonitor)

/**
 viewDidLoad，页面渲染时长起始点
 @discussion 在vc push之前访问 view 将导致统计值偏大
 @note 页面渲染时长在vc生命周期内只统计一次
 */
- (void)UCARMonitor_viewDidLoad;


/**
 viewWillAppear，页面使用时长起始点
 @note 页面使用时长在vc生命周期内会统计多次
 */
- (void)UCARMonitor_viewWillAppear;


/**
 viewDidAppear，页面渲染时长结束点
 */
- (void)UCARMonitor_viewDidAppear;


/**
 viewWillDisappear，页面使用时长结束点
 */
- (void)UCARMonitor_viewWillDisappear;

@end
