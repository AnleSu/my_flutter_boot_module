//
//  ZCOneButtonBottomView.h
//  ZCBusiness
//
//  Created by 曹志勇 on 2019/2/18.
//  Copyright © 2019 UCAR. All rights reserved.
//

// import分组次序：Frameworks、Services、UI
#import <UIKit/UIKit.h>

#pragma mark - @class

#pragma mark - 常量

#pragma mark - 枚举

NS_ASSUME_NONNULL_BEGIN

/**
 * 底部按钮展示页面
 * @note 回调用block 传btn的title过去
 */
@interface ZCOneButtonBottomView : UIView

@property (nonatomic, copy) NSString *buttonTitle;
@property (nonatomic, copy) void (^clickBottomBtn)(NSString *title);

// 开放bottomButton 方便调用者自定义一些属性参数
@property (nonatomic, readonly, strong) UIButton *bottomButton;

@end

NS_ASSUME_NONNULL_END
