//
//  ZCQRCodeScanViewController.m
//  ZCBusiness
//
//  Created by ZhangYuqing on 2019/3/3.
//  Copyright © 2019 UCAR. All rights reserved.
//

// import分组次序：Frameworks、Services、UI
#import "UCARQRCodeScanViewController.h"
#import <UCARScanView.h>
#import <AVFoundation/AVFoundation.h>
#import <ZBarSDK/ZBarSDK.h>
#import <Masonry/Masonry.h>
#import <Photos/PHPhotoLibrary.h>

@interface UCARQRCodeScanViewController ()<UCARScanViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

#pragma mark - 私有属性
@property (strong,nonatomic) CIDetector *detector;
@property (strong,nonatomic) UCARScanView *scanview;
@property (assign,nonatomic) BOOL hasCameraAccess;
@end

@implementation UCARQRCodeScanViewController

#pragma mark - Life cycle
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.shouldAutoPop = YES;
        self.shouldAnimationPop = YES;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device)
        {
            // 判断授权状态
            dispatch_async(dispatch_get_main_queue(), ^{
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (authStatus == AVAuthorizationStatusAuthorized)
                {
                    self.hasCameraAccess = YES;
                }
            });
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.hasCameraAccess)
    {
//        [self addCameraView];
    }
    else
    {
        [self grantToCamera];
    }
}


- (void)addCameraView
{
    if (!self.hasCameraAccess)
    {
        return;
    }
    UCARScanView *scanview = [[UCARScanView alloc] init];
    scanview.delegate = self;
    [self.view addSubview:scanview];
    self.scanview = scanview;
    if (self.titleString.length > 0)
    {
        [self.scanview setTitleString:self.titleString];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏navigationBar
    self.navigationController.navigationBarHidden = YES;
    // 是否允许右滑返回
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
//    if (self.scanview)
//    {
        NSLog(@"重新添加相机View");
        [self addCameraView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.33 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.scanview startScanLineAnimation];
        });
//    }
//    else
//    {
//        NSLog(@"启动动画效果");
//        [self.scanview startScanLineAnimation];
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.scanview.lightButton.isSelected)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scanview light_buttonAction:self.scanview.lightButton];
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc {
    NSLog(@"%@ - dealloc", NSStringFromClass([self class]));
}

- (void)popToViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showTheAlbum
{
    if (@available(iOS 11.0, *))
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusNotDetermined || status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showPhotoLibray];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertView];
                });
            }
        }];
    }
    else
    {
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (authStatus == PHAuthorizationStatusRestricted|| authStatus == PHAuthorizationStatusDenied) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertView];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showPhotoLibray];
            });
        }
    }
}

- (void)showPhotoLibray
{
    if (self.scanview.lightButton.isSelected)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scanview light_buttonAction:self.scanview.lightButton];
        });
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    //    picker.allowsEditing=YES;
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:picker animated:YES completion:nil];
    });
}



- (void)showAlertView
{
    UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    }];
    UIAlertAction *setUpAlert = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancelAlert];
    [alert addAction:setUpAlert];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}



- (void)ZCScanViewOutputMetadataObjects:(NSArray *)metadataObjs
{
    // 扫描到二维码的结果回调
    AVMetadataMachineReadableCodeObject *obj = [metadataObjs objectAtIndex:0];
    NSLog(@"码数据:%@",obj.stringValue);
    NSLog(@"码类型:%@",obj.type);
    if (self.delegate && [self.delegate respondsToSelector:@selector(scanResult:)])
    {
        [self.delegate scanResult:obj.stringValue];
        [self hasResultPop];
    }
}


//完成图片的选取后回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //选取完图片后跳转回原控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    //从info中将图片取出，并加载到imageview当中
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *alertImage = [self alterImageSize:image];
    // 取得识别结果
    NSArray *features = [self detectWithImage:alertImage];
    NSString *resultStr;
    if (features.count == 0)
    {
          [self zbar_recoginzeImage:alertImage];
    }
    else
    {
        for (int index = 0; index < [features count]; index ++)
        {
            CIQRCodeFeature *feature = [features objectAtIndex:index];
            resultStr = feature.messageString;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(scanResult:)] && resultStr.length > 0)
        {
            [self.delegate scanResult:resultStr];
            [self hasResultPop];
        }
        else
        {
            [self zbar_recoginzeImage:alertImage];
        }
    }
}

//取消选取调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)detectWithImage:(UIImage *)img
{
    // prepare CIImage
    NSData *imageData = UIImagePNGRepresentation(img);
    CIImage *image = [CIImage imageWithData:imageData];;
    NSArray *features = [self.detector featuresInImage:image];
    return features;
}


-(UIImage *)alterImageSize:(UIImage *)originalImage
{
    UIGraphicsBeginImageContext(originalImage.size);
    [originalImage drawInRect:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
    UIImage *NewImage = [UIImage imageWithCGImage:[UIGraphicsGetImageFromCurrentImageContext() CGImage]];
    return NewImage;
}


- (void)zbar_recoginzeImage:(UIImage *)image
{
    UIImage *aImage = image;
    ZBarReaderController *read = [[ZBarReaderController alloc]init];
    CGImageRef cgImageRef = aImage.CGImage;
    ZBarSymbol *symbol = nil;
    for (ZBarSymbol *tempsymbol in [read scanImage:cgImageRef])
    {
        NSString *strCode = tempsymbol.data;
        if (strCode.length > 0)
        {
            symbol = tempsymbol;
        }
    }
    if (symbol)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(scanResult:)])
        {
            [self.delegate scanResult:symbol.data];
            [self hasResultPop];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(scanNotfindQRCode)])
        {
            [self.delegate scanNotfindQRCode];
        }
    }
}

- (void)hasResultPop
{
    if (self.shouldAutoPop)
    {
        if (self.shouldAnimationPop)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

- (void)grantToCamera
{
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device)
    {
        // 判断授权状态
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted)
        {
            UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法开启相机" message:@"请在iPhone的“设定-隐私-相机”选项中,允许“宝沃新零售商户端”访问你的相机。" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:cancelAlert];
            [alert addAction:settingAction];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            return;
        }
        else if (authStatus == AVAuthorizationStatusDenied)
        { // 用户拒绝当前应用访问相机
            UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法开启相机" message:@"请在iPhone的“设定-隐私-相机”选项中,允许“宝沃新零售商户端”访问你的相机。" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:cancelAlert];
            [alert addAction:settingAction];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            return;
        }
        else if (authStatus == AVAuthorizationStatusAuthorized)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 用户允许当前应用访问相机
                self.hasCameraAccess = YES;
                [self addCameraView];
            });
        }
        else if (authStatus == AVAuthorizationStatusNotDetermined)
        { // 用户还没有做出选择
            // 弹框请求用户授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    // 用户接受
                    self.hasCameraAccess = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addCameraView];
                    });

                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }
            }];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"未检测到您的摄像头, 请在真机上测试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alertView show];
    }

}
@end
