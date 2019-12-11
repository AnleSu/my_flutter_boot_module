//
//  BottomAnimationView.m
//  LivenessDetection
//
//  Created by 张英堂 on 15/1/8.
//  Copyright (c) 2015年 megvii. All rights reserved.
//

#import "MGBaseBottomManager.h"
#import "UIImageView+MGReadImage.h"


@interface MGBaseBottomManager ()


@end

@implementation MGBaseBottomManager

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self creatBottomView];
        [self creatAniamtionView];
        
        [self recovery];
    }
    return self;
}

- (void)creatBottomView{
    [self setBackgroundColor:MGColorWithRGB(51, 56, 70, 1)];
    
    
}

- (void)creatAniamtionView{
}

- (void)recovery{
    _stopAnimaiton = YES;
    [[MGPlayAudio sharedAudioPlayer] cancelAllPlay];
    
    [self recoveryView];
}

- (void)recoveryView{

}

- (void)recoveryWithTitle:(NSString *)title{
    [self recovery];
}


- (void)willChangeAnimation:(MGLivenessDetectionType)state outTime:(CGFloat)time currentStep:(NSInteger)step{
    _stopAnimaiton = NO;
}

- (void)startRollAnimation{
}


-(void)addSubview:(UIView *)view{
    if (view.superview == self) {
        return;
    }
    [super addSubview:view];
}

@end
