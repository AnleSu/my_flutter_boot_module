//
//  ZCQRCodeScanViewController.h
//  ZCBusiness
//
//  Created by ZhangYuqing on 2019/3/3.
//  Copyright © 2019 UCAR. All rights reserved.
//

// import分组次序：Frameworks、Services、UI
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UCARQRCodeScanViewControllerDelegate <NSObject>

- (void)scanResult:(NSString *)scanResult;
- (void)scanNotfindQRCode;
@end

/**
 * 扫码的主控制器界面逻辑
 * @note 扫码的主界面逻辑
 */
@interface UCARQRCodeScanViewController : UIViewController
@property (weak,nonatomic) id<UCARQRCodeScanViewControllerDelegate> delegate;
/**
 是否自动pop 默认为YES可根据业务类型选择
 */
@property (assign,nonatomic) BOOL shouldAutoPop;
/**
 是否需要带动画Pop默认带动画
 */
@property (assign,nonatomic) BOOL shouldAnimationPop;
/**
 titleString
 */
@property (strong,nonatomic) NSString *titleString;
@end

NS_ASSUME_NONNULL_END
