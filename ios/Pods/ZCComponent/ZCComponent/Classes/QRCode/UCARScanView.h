//
//  ZCScanView.h
//  ZCBusiness
//
//  Created by ZhangYuqing on 2019/3/3.
//  Copyright © 2019 UCAR. All rights reserved.
//

// import分组次序：Frameworks、Services、UI
#import <UIKit/UIKit.h>

@protocol UCARScanViewDelegate <NSObject>

- (void)ZCScanViewOutputMetadataObjects:(NSArray*)metadataObjs;

- (void)popToViewController;

- (void)showTheAlbum;

@end

/**
 * 条形码扫描的展示View
 * @note 条形码扫描的展示View
 */
@interface UCARScanView : UIView
@property (nonatomic, assign) id<UCARScanViewDelegate> delegate;
@property (strong,nonatomic) UIButton *lightButton;
- (void)light_buttonAction:(UIButton *)button;
- (void)startScanLineAnimation;
- (void)setTitleString:(NSString *)titleString;
/**
 是否继续扫描的方法
 @param isStartScan 是否开始扫描
 */
- (void)startOrStopScaning:(BOOL)isStartScan;
- (void)showAV;
@end

