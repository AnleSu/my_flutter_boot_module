//
//  UCarSmaertOCRResultViewController.h
//  CMTPlatform
//
//  Created by ZhangYuqing on 2019/4/23.
//  Copyright © 2019 UCAR. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface UCarSmartOCRResultViewController : UIViewController
@property (strong,nonatomic) UIImage *resultImage;
@property (copy,nonatomic) NSString *resultString;
@property (assign,nonatomic) BOOL hasSearchAccess;
@end

NS_ASSUME_NONNULL_END
