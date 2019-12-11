//
//  UCARUIKitConfigInstance.h
//  UCARUIKit
//
//  Created by linux on 28/02/2018.
//

#import <Foundation/Foundation.h>
#import "UCARUIKitConfig.h"
#import "UCARLoadingViewProtocol.h"
#import "UCARPullLoadingViewProtocol.h"

@protocol UCARUIKitConfigDataSource <NSObject>
@required

/**
 you must set the size of loadingView

 @return loadingView
 */
- (UIView<UCARLoadingViewProtocol> *)loadingView;
/**
 you must set the size of pullLoadingView
 
 @return pullLoadingView
 */
- (UIView<UCARPullLoadingViewProtocol> *)pullLoadingView;

@end

@interface UCARUIKitConfigInstance : NSObject


/**
 UCARProgressManager showMessageUseAlert中按钮名称
 */
@property (nonatomic, copy) NSString *progressAlertButtonTitle;

@property (nonatomic, strong) UCARToastViewConfig *toastViewConfig;
@property (nonatomic, strong) UCARAlertViewConfig *alertViewConfig;

/**
 the dataSource will be retained by configInstance
 */
@property (nonatomic, weak) id<UCARUIKitConfigDataSource> dataSource;

+ (instancetype)sharedConfig;

@end
