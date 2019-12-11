//
//  NSString+UCARUIKit.m
//  Pods-ZCComponent_Example
//
//  Created by 郑熙 on 2019/4/25.
//

#import "NSString+ZCComponent.h"

@implementation NSString (ZCComponent)

- (BOOL)hasString:(NSString * _Nonnull)substring {
    return [self hasString:substring caseSensitive:YES];
}

- (BOOL)hasString:(NSString *)substring caseSensitive:(BOOL)caseSensitive {
    if (caseSensitive) {
        return [self rangeOfString:substring].location != NSNotFound;
    } else {
        return [self.lowercaseString rangeOfString:substring.lowercaseString].location != NSNotFound;
    }
}

- (BOOL)isEmail {
    return [NSString isEmail:self];
}

+ (BOOL)isEmail:(NSString * _Nonnull)email {
    NSString *emailRegEx = @"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
    
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:[email lowercaseString]];
}

- (NSString * _Nonnull)URLEncode {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

- (CGFloat)heightForWidth:(float)width andFont:(UIFont * _Nonnull)font {
    CGSize size = CGSizeZero;
    if (self.length > 0) {
        CGRect frame = [self boundingRectWithSize:CGSizeMake(width, 999999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    return size.height;
}

@end
