//
//  UCARNumberKeyBoard.h
//  IdentityCardInput
//
//  Created by KouArlen on 15/7/16.
//  Copyright (c) 2015年 KouArlen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UCARNumberKeyBoardType)
{
    UCARNumberKeyBoardTypeNone = 0,
    //完成
    UCARNumberKeyBoardTypeDone = 1,
    //身份证
    UCARNumberKeyBoardTypeID = 2,
    //浮点数
    UCARNumberKeyBoardTypeFloat = 3
};

typedef NS_ENUM(NSInteger, UCARNumberKeyBoardClickType)
{
    //input，上9键 + 底部中键
    UCARNumberKeyBoardClickTypeInput,
    //delete，底部右键
    UCARNumberKeyBoardClickTypeDelete,
    //userDefined，底部左键
    UCARNumberKeyBoardClickTypeUserDefined
};

typedef void(^UCARNumberKeyBoardBlock)(NSString *input, UCARNumberKeyBoardClickType clickType, NSInteger inputTag);

@interface UCARNumberKeyBoard : UIView

//左下角什么也没有
+ (UCARNumberKeyBoard *)keyBoard;
//自定义一个左下角字符，默认字号为22
+ (UCARNumberKeyBoard *)keyBoardWithTitle:(NSString *)title;
//自定义一个左下角字符
+ (UCARNumberKeyBoard *)keyBoardWithAttrTitle:(NSAttributedString *)title;

@property (nonatomic, copy) UCARNumberKeyBoardBlock clickBlock;
//textField's tag，此属性用于标识当前输入的textfield
@property (nonatomic, assign) NSInteger inputTag;

@end
