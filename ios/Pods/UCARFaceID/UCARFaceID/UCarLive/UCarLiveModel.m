//
//  UCarLiveModel.m
//  UCarLive
//
//  Created by huyujin on 16/10/11.
//  Copyright © 2016年 UCarInc. All rights reserved.
//

#import "UCarLiveModel.h"

@implementation UCarLiveModel

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        
        id result_faceid = [dict objectForKey:@"result_faceid"];
        if ([result_faceid isKindOfClass:[NSDictionary class]]) {
            self.result_faceid = result_faceid;
        }
        
        id verify_result = [dict objectForKey:@"verify_result"];
        if ([verify_result isKindOfClass:[NSString class]] || [verify_result isKindOfClass:[NSNumber class]]) {
            self.verify_result = [verify_result boolValue];
        }
        
        id image1_url = [dict objectForKey:@"image1_url"];
        if ([image1_url isKindOfClass:[NSString class]]) {
            self.image1_url = image1_url;
        }
        
        /**
            兼容以下两个接口：
            1. verifyFace
            2. verifyIDCardAndFace
         */
        id image2_url = [dict objectForKey:@"image_url"];
        if ([image2_url isKindOfClass:[NSString class]]) {
            self.image2_url = image2_url;
        }else {
            image2_url = [dict objectForKey:@"image2_url"];
            if ([image2_url isKindOfClass:[NSString class]]) {
                self.image2_url = image2_url;
            }
        }
        
        id error_message = [dict objectForKey:@"error_message"];
        if ([error_message isKindOfClass:[NSString class]]) {
            self.error_message = error_message;
        }
    }
    return self;
}

@end
