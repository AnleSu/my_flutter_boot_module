//
//  UIView+ZCUtility.h
//  ZCBusiness
//
//  Created by 郑熙 on 2019/2/20.
//  Copyright © 2019 UCAR. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  线性渐变色的方向
 */
typedef NS_ENUM(NSInteger, UIViewLinearGradientDirection) {
    /**
     *  Linear gradient vertical
     */
    UIViewLinearGradientDirectionVertical = 0,
    /**
     *  Linear gradient horizontal
     */
    UIViewLinearGradientDirectionHorizontal,
    /**
     *  Linear gradient from left to right and top to down
     */
    UIViewLinearGradientDirectionDiagonalFromLeftToRightAndTopToDown,
    /**
     *  Linear gradient from left to right and down to top
     */
    UIViewLinearGradientDirectionDiagonalFromLeftToRightAndDownToTop,
    /**
     *  Linear gradient from right to left and top to down
     */
    UIViewLinearGradientDirectionDiagonalFromRightToLeftAndTopToDown,
    /**
     *  Linear gradient from right to left and down to top
     */
    UIViewLinearGradientDirectionDiagonalFromRightToLeftAndDownToTop
};

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZCComponent)

/**
 *  Create a border around the UIView
 *
 *  @param color  Border's color
 *  @param radius Border's radius
 *  @param width  Border's width
 */
- (void)createBordersWithColor:(UIColor * _Nonnull)color
              withCornerRadius:(CGFloat)radius
                      andWidth:(CGFloat)width;

/**
 *  Remove the borders around the UIView
 */
- (void)removeBorders;

/**
 *  Create a shadow on the UIView
 *
 *  @param offset  Shadow's offset
 *  @param opacity Shadow's opacity
 *  @param radius  Shadow's radius
 */
- (void)createRectShadowWithOffset:(CGSize)offset
                           opacity:(CGFloat)opacity
                            radius:(CGFloat)radius;

/**
 *  Create a corner radius shadow on the UIView
 *
 *  @param cornerRadius Corner radius value
 *  @param offset       Shadow's offset
 *  @param opacity      Shadow's opacity
 *  @param radius       Shadow's radius
 */
- (void)createCornerRadiusShadowWithCornerRadius:(CGFloat)cornerRadius
                                          offset:(CGSize)offset
                                         opacity:(CGFloat)opacity
                                          radius:(CGFloat)radius;

/**
 *  Remove the shadow around the UIView
 */
- (void)removeShadow;

/**
 *  Set the corner radius of UIView
 *
 *  @param radius Radius value
 */
- (void)setCornerRadius:(CGFloat)radius;

/**
 *  Create a linear gradient
 *
 *  @param colors    NSArray of UIColor instances
 *  @param direction Direction of the gradient
 */
- (void)createGradientWithColors:(NSArray * _Nonnull)colors
                       direction:(UIViewLinearGradientDirection)direction;

/**
 *  Take a screenshot of the current view
 *
 *  @return Returns screenshot as UIImage
 */
- (UIImage * _Nonnull)screenshot;

/**
 *  Take a screenshot of the current view an saving to the saved photos album
 *
 *  @return Returns screenshot as UIImage
 */
- (UIImage * _Nonnull)saveScreenshot;

/**
 *  Removes all subviews from current view
 */
- (void)removeAllSubviews;

@end

NS_ASSUME_NONNULL_END
