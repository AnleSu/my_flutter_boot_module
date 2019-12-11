//
//  UCAROCRViewController.h
//  Masonry
//
//  Created by Link on 2019/8/12.
//

#import <UIKit/UIKit.h>

//NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, UCAROCRTypes) {
    UCAROCRType_None        = 0,
    UCAROCRType_VIN         = 1 << 0,               //车架号
    UCAROCRType_PlateNum    = 1 << 1,               //车牌号
    UCAROCRType_QRCode      = 1 << 2,               //二维码和条形码
    //暂未开放
    //UCAROCRType_IDCard      = 1 << 3,               //身份证
};


@protocol UCARScanViewControllerDelegate <NSObject>

@optional
//扫描成功
- (void)ucarScanResult:(NSString *)result image:(UIImage *)resImg ocrType:(UCAROCRTypes)type;

@end


@interface UCARScanViewController : UIViewController

@property (nonatomic, weak) id<UCARScanViewControllerDelegate> delegate;

/**
 是否自动pop 默认为YES可根据业务类型选择
 */
@property (nonatomic, assign, readwrite) BOOL autoPopViewController;


/**
  用来初始化OCR自由组合的类型, 显示位置固定 车架号-车牌-二维码

 @param types UCAROCRType类型，可以通过 | 来自由组合类型
 例如参数:
    UCAROCRType_QRCode | UCAROCRType_PlateNum | UCAROCRType_VIN
 */
- (instancetype)initWithOCRTypes:(UCAROCRTypes)types;



/**
 用来初始化OCR自由组合的类型，显示位置根据传入数组的位置

 @param types 传入的数组值为 @(UCAROCRTypes),例如
 @[@(UCAROCRType_QRCode), @(UCAROCRType_VIN)]
 */
- (instancetype)initWithOCRKinds:(NSArray<NSNumber *> *)types;
@end

//NS_ASSUME_NONNULL_END
