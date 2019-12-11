//
//  UCARToastView.h
//  UCar
//
//  Created by KouArlen on 16/3/18.
//  Copyright © 2016年 zuche. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UCARToastIconType) {
    UCARToastIconTypeNone,
    UCARToastIconTypeSuccess,
    UCARToastIconTypeFail,
    UCARToastIconTypeInfo,
};

@interface UCARToastView : UIView

- (void)setText:(nonnull NSString *)text iconType:(UCARToastIconType)iconType;

@end
