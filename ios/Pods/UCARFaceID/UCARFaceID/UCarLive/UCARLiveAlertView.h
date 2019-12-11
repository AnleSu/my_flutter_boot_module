//
//  UCARLiveAlertView.h
//  UCarLive
//
//  Created by 宣佚 on 2017/6/21.
//  Copyright © 2017年 UCarInc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UcarLiveConfirmBtnBlock)();

@interface UCARLiveAlertView : UIView

- (instancetype)initWithTitle:(NSString *)t_title message:(NSString *)t_message containerView:(UIView *)t_containerView btnBlock:(UcarLiveConfirmBtnBlock)t_block;

- (void)show;

@end
