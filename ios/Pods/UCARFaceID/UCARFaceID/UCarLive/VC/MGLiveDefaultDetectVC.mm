//
//  MGLiveDefaultDetectVC.m
//  MGLivenessDetection
//
//  Created by 张英堂 on 16/8/17.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGLiveDefaultDetectVC.h"

@interface MGLiveDefaultDetectVC ()

@end

@implementation MGLiveDefaultDetectVC

/** 活体检测结束处理 */
- (void)liveDetectionFinish:(MGLivenessDetectionFailedType)type checkOK:(BOOL)check liveDetectionType:(MGLiveDetectionType)detectionType {
    [super liveDetectionFinish:type checkOK:check liveDetectionType:detectionType];
    
    if (check == YES) {
        if (detectionType == MGLiveDetectionTypeQualityOnly) {
            if (self.Qualityfinish) {
                self.Qualityfinish([self.liveManager getBestQualityFrame], self.navigationController);
            }
        }else {
            FaceIDData *faceData = [self.liveManager getFaceIDData];
            
            if (self.detectFinish){
                self.detectFinish(faceData, self.navigationController);
            }
        }
    }else{
        if (self.detectError)
        self.detectError(type, self.navigationController);
    }
    
}

#pragma mark -

- (void)backAction:(UIButton *)sender {
    NSLog(@"back button clicked");
    
    [self liveDetectionFinish:DETECTION_FAILED_TYPE_CANCEL checkOK:NO liveDetectionType:MGLiveDetectionTypeAll];
}



@end
