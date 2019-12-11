//
//  UCARShareSDK.h
//  UCARShareSDK
//
//  Created  by hong.zhu on 2019/2/22.
//  Copyright © 2019年 UCARINC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCARShareSDKDelegate.h"
#import "UCARShareItem.h"
#import "UCARSDKSetupTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCARShareSDK : NSObject

/**
 初始化ShareSDK应用

 @param activePlatforms 使用的分享平台集合，如:@[@(UCARShareTypeWeChatSession), @(UCARShareTypeQQSession)]
 @param configurationHandler 配置回调处理，在此方法中根据设置的 shareType 来填充应用配置信息
 */
+ (void)registerActivePlatforms:(NSArray *)activePlatforms
                onConfiguration:(UCARKConfigurationHandler)configurationHandler;

/**
 通过 delegate 获取实例
 */
+ (instancetype)shareSDKWithDelegate:(id<UCARShareSDKDelegate>)delegate;

// handleOpenURL
+ (BOOL)handleOpenURL:(NSURL *)url;

#pragma mark -
#pragma mark - 分享
/**
 分享

 @param shareItem 分享数据
 @return 返回调取分享接口(并非最终结果)
 */
- (NSString*)shareSDKWithItem:(UCARShareItem*)shareItem;

/**
 当前的分享方式
 @note 分享结束, 手动设置成 UCARShareTypeNone
 */
@property (nonatomic, assign) UCARShareType shareType;

#pragma mark -
#pragma mark - 安装
/**
 *  是否安装客户端（支持平台：微博、微信、QQ、QZone）
 *
 *  @param shareType 平台类型
 *
 *  @return YES 已安装，NO 尚未安装
 */
+ (BOOL)isClientInstalledWithShareType:(UCARShareType)shareType;

@end

NS_ASSUME_NONNULL_END
