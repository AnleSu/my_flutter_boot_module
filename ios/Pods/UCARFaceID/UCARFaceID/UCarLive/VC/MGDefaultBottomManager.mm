//
//  MGDefaultBottomManager.m
//  MGLivenessDetection
//
//  Created by 张英堂 on 16/4/13.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGDefaultBottomManager.h"
#import "UIImageView+MGReadImage.h"
#import "MGBaseKit.h"
#import "UCARLive_Color.h"


static CGFloat topToPhone = 13*UCARLIVE_SCALE;
static CGFloat phoneWidth = 224*UCARLIVE_SCALE;
static CGFloat phoneToTips = 47*UCARLIVE_SCALE;
static CGFloat tipsHeight = 11*UCARLIVE_SCALE;
static CGFloat tipsToTempface = 18*UCARLIVE_SCALE;
static CGFloat tempfaceHeight = 80*UCARLIVE_SCALE;


@interface MGDefaultBottomManager ()

@property (nonatomic, strong) UIImageView *tempFaceImageview;
@property (nonatomic, strong) UIImageView *phoneImageView;
@property (nonatomic, strong) UIView *phoneView;
@property (nonatomic, strong) UILabel *msgLabel;


@end

@implementation MGDefaultBottomManager

- (UIImageView *)tempFaceImageview {
    if (!_tempFaceImageview) {
        CGFloat center = (phoneWidth - tempfaceHeight) / 2;
        CGFloat top = phoneToTips + tipsHeight + tipsToTempface;
        if (iPhoneX) {
            top += 50*UCARLIVE_SCALE;
        }
        _tempFaceImageview = [[UIImageView alloc] initWithFrame:CGRectMake(center, top,  tempfaceHeight, tempfaceHeight)];
        _tempFaceImageview.image = [MGLiveBundle LiveImageWithName:@"openeye"];
        [_tempFaceImageview setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _tempFaceImageview;
}

- (UIImageView *)phoneImageView {
    if (!_phoneImageView) {
        CGFloat height = self.frame.size.height;
        _phoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, phoneWidth, (height-topToPhone))];
        _phoneImageView.backgroundColor = [UIColor clearColor];
        _phoneImageView.image = [MGLiveBundle LiveImageWithName:@"phone"];
        [_phoneImageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _phoneImageView;
}

- (UIView *)phoneView {
    if (!_phoneView) {
        CGFloat height = self.frame.size.height;
        _phoneView = [[UIView alloc] initWithFrame:CGRectMake((UCARLIVE_SCREEN_WIDTH-phoneWidth)/2, topToPhone, phoneWidth, (height-topToPhone))];
    }
    return _phoneView;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        CGFloat h = phoneToTips;
        if (iPhoneX) {
            h += 50*UCARLIVE_SCALE;
        }
        _msgLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, h, phoneWidth, tipsHeight)];
        _msgLabel.font = [UIFont systemFontOfSize:(12*UCARLIVE_SCALE)];
        _msgLabel.textColor = UCARLIVE_UIColorFromRGB(0x404041);
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.text = @"拿起手机眨眨眼";
    }
    return _msgLabel;
}

- (void)creatBottomView{
    [super creatBottomView];
    
    self.backgroundColor = UCARLIVE_UIColorFromRGB(0xffffff);
    
    [self addSubview:self.phoneView];
    [self.phoneView addSubview:self.phoneImageView];
    [self.phoneView insertSubview:self.msgLabel aboveSubview:self.phoneImageView];
    [self.phoneView insertSubview:self.tempFaceImageview aboveSubview:self.phoneImageView];
}

- (void)creatAniamtionView{
    [super creatAniamtionView];
}

- (void)recoveryView{
    [super recoveryView];
}

- (void)willChangeAnimation:(MGLivenessDetectionType)state outTime:(CGFloat)time currentStep:(NSInteger)step {
    
    [super willChangeAnimation:state outTime:time currentStep:step];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    NSString *videoName = nil;
    
    switch (state) {
        case DETECTION_TYPE_BLINK:
        {
            [array addObject:[MGLiveBundle LiveImageWithName:@"closeeye"]];
            [array addObject:[MGLiveBundle LiveImageWithName:@"openeye"]];
            videoName = @"meglive_eye_blink2";
            break;
        }
        default:
            break;
    }
    
    if (step == 0) {
        [[MGPlayAudio sharedAudioPlayer] playWithFileName:videoName finishNext:NO];
    }else{
        [[MGPlayAudio sharedAudioPlayer] playWithFileName:videoName finishNext:YES];
    }
    
    if (array.count != 0) {
        
        [self.tempFaceImageview setAnimationImages:array];
        [self.tempFaceImageview setAnimationRepeatCount:999];
        [self.tempFaceImageview setAnimationDuration:1.5f];
        [self.tempFaceImageview startAnimating];
    }
}

@end
