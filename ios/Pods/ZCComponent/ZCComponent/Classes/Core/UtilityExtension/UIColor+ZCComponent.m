//
//  UIColor+UCARUIKit.m
//  Masonry
//
//  Created by 郑熙 on 2019/4/27.
//

#import "UIColor+ZCComponent.h"

@implementation UIColor (ZCComponent)

+ (UIColor * _Nonnull)hex:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue = [self colorComponentFrom:colorString start:3 length:1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue = [self colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue = [self colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            return nil;
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor * _Nonnull )hexString:(NSString *)hexString {
    return [UIColor hex:hexString];
}

+ (id _Nonnull)colorWithHex:(unsigned int)hex {
    return [UIColor colorWithHex:hex alpha:1.0];
}

+ (id _Nonnull)colorWithHex:(unsigned int)hex alpha:(float)alpha {
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString * _Nonnull)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    
    return hexComponent / 255.0;
}

+ (UIColor * _Nonnull)randomColor {
    int r = arc4random() % 255;
    int g = arc4random() % 255;
    int b = arc4random() % 255;
    
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

+ (UIColor * _Nonnull)colorWithColor:(UIColor * _Nonnull)color alpha:(float)alpha {
    return [color colorWithAlphaComponent:alpha];
}

- (BOOL)canProvideRGBComponents {
    switch (CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))) {
        case kCGColorSpaceModelRGB:
        case kCGColorSpaceModelMonochrome:
            return YES;
        default:
            return NO;
    }
}

- (CGFloat)red {
    if (self.canProvideRGBComponents) {
        const CGFloat *c = CGColorGetComponents(self.CGColor);
        return c[0];
    }
    
    return 0.0;
}

- (CGFloat)green {
    if (self.canProvideRGBComponents) {
        const CGFloat *c = CGColorGetComponents(self.CGColor);
        if (CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor)) == kCGColorSpaceModelMonochrome)
            return c[0];
        return c[1];
    }
    
    return 0.0;
}

- (CGFloat)blue {
    if (self.canProvideRGBComponents) {
        const CGFloat *c = CGColorGetComponents(self.CGColor);
        if (CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor)) == kCGColorSpaceModelMonochrome)
            return c[0];
        return c[2];
    }
    
    return 0.0;
}

@end
