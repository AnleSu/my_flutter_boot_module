//
//  UCARCIDBundleManager.h
//  UCARCertifyID
//
//  Created by 宣佚 on 2018/1/9.
//

#import <Foundation/Foundation.h>

@interface UCARCIDBundleManager : NSObject

+ (instancetype)sharedInstance;
- (UIImage *)imageName:(NSString *)name;
- (void)getCameraAuth:(void(^)(BOOL ispass))block;

@end
