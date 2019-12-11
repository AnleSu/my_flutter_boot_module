//
//  UIView+ZCUtility.m
//  ZCBusiness
//
//  Created by 郑熙 on 2019/2/20.
//  Copyright © 2019 UCAR. All rights reserved.
//

#import "UIView+ZCComponent.h"

@implementation UIView (ZCComponent)

- (void)createBordersWithColor:(UIColor * _Nonnull)color withCornerRadius:(CGFloat)radius andWidth:(CGFloat)width {
    self.layer.borderWidth = width;
    self.layer.cornerRadius = radius;
    self.layer.shouldRasterize = NO;
    self.layer.rasterizationScale = 2;
    self.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGColorRef cgColor = [color CGColor];
    self.layer.borderColor = cgColor;
    CGColorSpaceRelease(space);
}

- (void)removeBorders {
    self.layer.borderWidth = 0;
    self.layer.cornerRadius = 0;
    self.layer.borderColor = nil;
}

- (void)createRectShadowWithOffset:(CGSize)offset opacity:(CGFloat)opacity radius:(CGFloat)radius {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.masksToBounds = NO;
}

- (void)createCornerRadiusShadowWithCornerRadius:(CGFloat)cornerRadius offset:(CGSize)offset opacity:(CGFloat)opacity radius:(CGFloat)radius {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shouldRasterize = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:cornerRadius] CGPath];
    self.layer.masksToBounds = NO;
}

- (void)removeShadow {
    [self.layer setShadowColor:[[UIColor clearColor] CGColor]];
    [self.layer setShadowOpacity:0.0f];
    [self.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
}

- (void)setCornerRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    [self.layer setMasksToBounds:YES];
}

- (void)createGradientWithColors:(NSArray * _Nonnull)colors direction:(UIViewLinearGradientDirection)direction {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    
    NSMutableArray *mutableColors = colors.mutableCopy;
    for (int i = 0; i < colors.count; i++) {
        UIColor *currentColor = colors[i];
        [mutableColors replaceObjectAtIndex:i withObject:(id)currentColor.CGColor];
    }
    gradient.colors = mutableColors;
    
    switch (direction) {
        case UIViewLinearGradientDirectionVertical: {
            gradient.startPoint = CGPointMake(0.5f, 0.0f);
            gradient.endPoint = CGPointMake(0.5f, 1.0f);
            break;
        }
        case UIViewLinearGradientDirectionHorizontal: {
            gradient.startPoint = CGPointMake(0.0f, 0.5f);
            gradient.endPoint = CGPointMake(1.0f, 0.5f);
            break;
        }
        case UIViewLinearGradientDirectionDiagonalFromLeftToRightAndTopToDown: {
            gradient.startPoint = CGPointMake(0.0f, 0.0f);
            gradient.endPoint = CGPointMake(1.0f, 1.0f);
            break;
        }
        case UIViewLinearGradientDirectionDiagonalFromLeftToRightAndDownToTop: {
            gradient.startPoint = CGPointMake(0.0f, 1.0f);
            gradient.endPoint = CGPointMake(1.0f, 0.0f);
            break;
        }
        case UIViewLinearGradientDirectionDiagonalFromRightToLeftAndTopToDown: {
            gradient.startPoint = CGPointMake(1.0f, 0.0f);
            gradient.endPoint = CGPointMake(0.0f, 1.0f);
            break;
        }
        case UIViewLinearGradientDirectionDiagonalFromRightToLeftAndDownToTop: {
            gradient.startPoint = CGPointMake(1.0f, 1.0f);
            gradient.endPoint = CGPointMake(0.0f, 0.0f);
            break;
        }
    }
    [self.layer insertSublayer:gradient atIndex:0];
}

- (UIImage * _Nonnull)screenshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(image);
    image = [UIImage imageWithData:imageData];
    
    return image;
}

- (UIImage * _Nonnull)saveScreenshot {
    UIImage *image = [self screenshot];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    return image;
}

- (void)removeAllSubviews {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
