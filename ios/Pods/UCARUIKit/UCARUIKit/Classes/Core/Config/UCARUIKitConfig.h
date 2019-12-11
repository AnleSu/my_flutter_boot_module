//
//  UCARUIKitConfig.h
//  UCARUIKit
//
//  Created by linux on 28/02/2018.
//

#import <Foundation/Foundation.h>

/**
 为什么不使用UI_APPEARANCE_SELECTOR？
 
 UI_APPEARANCE_SELECTOR是个好技术，既支持统一配置又可单独定制，
 继承时子类亦可使用，
 但唯一的弊端就在于取值，需要掌握好取值的时机，对开发造成很多困扰。
 
 故使用config方式来实现相同效果
 config方式最大的弊端在于一个config只能对应一个class，子类不可复用
 */

@protocol UCARUIKitConfigProtocol <NSObject>
- (void)initConfig;
@end

@interface UCARUIKitConfig : NSObject <UCARUIKitConfigProtocol>

@end

@interface UCARToastViewConfig : UCARUIKitConfig

@property (nonatomic, strong, nonnull) UIColor *backgroundColor;
@property (nonatomic, strong, nonnull) UIColor *titleColor;
@property (nonatomic, strong, nonnull) UIFont *titleFont;

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGFloat iconSize;

@property (nonatomic, strong, nullable) UIImage *infoImage;
@property (nonatomic, strong, nullable) UIImage *successImage;
@property (nonatomic, strong, nullable) UIImage *failImage;

@end




/**
 弹框按钮布局样式

 - UCARAlertButtonLayoutStyleBorder: 司机端样式，描边
 - UCARAlertButtonLayoutStyleHammer: 通用样式，T字型分隔
 */
typedef NS_ENUM(NSInteger, UCARAlertButtonLayoutStyle) {
    UCARAlertButtonLayoutStyleBorder,
    UCARAlertButtonLayoutStyleHammer
};

@interface UCARAlertViewConfig : UCARUIKitConfig

@property (nonatomic, assign) UCARAlertButtonLayoutStyle buttonLayoutStyle;

@property (nonatomic, assign) BOOL isTitleMustCenter;
@property (nonatomic, assign) BOOL isMessageMustCenter;

@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) CGFloat padding;

@property (nonatomic, strong, nonnull) UIColor *titleColor;
@property (nonatomic, strong, nonnull) UIFont *titleFont;

@property (nonatomic, strong, nonnull) UIFont *noMessageTitleFont;

@property (nonatomic, strong, nonnull) UIColor *messageColor;
@property (nonatomic, strong, nonnull) UIFont *messageFont;

@end
