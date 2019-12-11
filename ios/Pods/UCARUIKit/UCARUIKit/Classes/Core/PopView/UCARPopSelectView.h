//
//  UCARPopSelectView.h
//  UCARUIKit
//
//  Created by linux on 29/01/2018.
//

#import <UCARUIKit/UCARUIKit.h>

@interface UCARPopSelectView : UCARPopBaseView

- (instancetype)initWithSelections:(NSArray<NSDictionary *> *)selections pointTarget:(UIView *)targetView inView:(UIView *)containerView withSelectedBlock:(void (^)(NSInteger index))selectedBlock;

- (instancetype)initWithSelections:(NSArray<NSDictionary *> *)selections pointTarget:(UIView *)targetView pointPosition:(UCARPopTipViewAnchorPointPosition)pointPosition inView:(UIView *)containerView withSelectedBlock:(void (^)(NSInteger index))selectedBlock;

- (void)show;
- (void)hide;

@end
