//
//  UCARPopBaseView.h
//  Masonry
//
//  Created by linux on 29/01/2018.
//

#import "UCARAnimationView.h"


typedef NS_ENUM(NSInteger, UCARPopTipViewAnchorPointPosition) {
    UCARPopTipViewAnchorPointPositionCenter,
    UCARPopTipViewAnchorPointPositionBoundary
};

typedef NS_ENUM(NSInteger, UCARPopTipViewAnchorDirection) {
    UCARPopTipViewAnchorDirectionUp,
    UCARPopTipViewAnchorDirectionDown
};

/*pop型提示，包含文案，按钮，指向三角
 *
 */
@interface UCARPopBaseView : UCARAnimationView

- (void)layoutContentView:(UIView *)contentView pointTarget:(UIView *)targetView pointPosition:(UCARPopTipViewAnchorPointPosition)pointPosition inView:(UIView *)containerView;

@end
