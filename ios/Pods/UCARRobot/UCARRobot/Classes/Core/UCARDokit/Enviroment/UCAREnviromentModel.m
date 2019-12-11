//
//  UCAREnviromentModel.m
//  UCARRobot
//
//  Created by suzhiqiu on 2019/7/2.
//

#import "UCAREnviromentModel.h"

@implementation UCAREnviromentModel
    
//支持加密编码
+ (BOOL)supportsSecureCoding {
    return YES;
}
//解码方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.envType = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(envType))];
        self.name = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(name))];
        self.desc = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(desc))];
        self.isOpen = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isOpen))];
    }
    return self;
}
//编码方法
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.envType forKey:NSStringFromSelector(@selector(envType))];
    [aCoder encodeObject:self.name forKey:NSStringFromSelector(@selector(name))];
    [aCoder encodeObject:self.desc forKey:NSStringFromSelector(@selector(desc))];
    [aCoder encodeBool:self.isOpen forKey:NSStringFromSelector(@selector(isOpen))];
}

@end
