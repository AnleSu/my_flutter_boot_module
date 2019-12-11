//
//  UCARPopBaseView.m
//  Masonry
//
//  Created by linux on 29/01/2018.
//

#import "UCARPopBaseView.h"

@interface UCARPopBaseView ()

@property (nonatomic, assign) CGFloat anchorSize;
@property (nonatomic, assign) UCARPopTipViewAnchorDirection anchorDirection;
@property (nonatomic, assign) CGPoint anchorPosition;

@property (nonatomic, assign) CGFloat padding;

@property (nonatomic, assign) CGFloat arcRadius;

@end

@implementation UCARPopBaseView

- (instancetype)initWithContainerView:(UIView *)containerView
{
    self = [super initWithContainerView:containerView];
    if (self) {
        self.anchorSize = 5.0;
        self.anchorDirection = UCARPopTipViewAnchorDirectionUp;
        self.anchorPosition = CGPointZero;
        self.padding = 10.0;
        self.arcRadius = 4.0;
    }
    return self;
}

- (void)layoutContentView:(UIView *)contentView pointTarget:(UIView *)targetView pointPosition:(UCARPopTipViewAnchorPointPosition)pointPosition inView:(UIView *)containerView
{
    BOOL hasContainerView = YES;
    if (!containerView) {
        hasContainerView = NO;
        containerView = targetView;
        while (containerView.superview) {
            if ([containerView.superview isKindOfClass:[UIWindow class]]) {
                containerView = containerView.superview;
                break;
            }
            containerView = containerView.superview;
        }
    }
    CGSize containerSize = containerView.bounds.size;

    CGFloat viewWidth = containerSize.width - self.padding * 2;
    CGFloat contentWidth = viewWidth - self.padding * 4;
    
    CGSize contentSize = contentView.frame.size;
    NSLog(@"%f, %f", contentSize.width, contentSize.height);
    if (contentWidth > contentSize.width) {
        contentWidth = contentSize.width;
        viewWidth = contentWidth + self.padding * 4;
    }
    
    CGFloat viewHeight = contentSize.height + self.anchorSize;
    
    CGPoint targetCenter = CGPointZero;
    if (hasContainerView) {
        targetCenter = [targetView.superview convertPoint:targetView.center toView:containerView];
    } else {
        CGSize targetSize = targetView.bounds.size;
        targetCenter = CGPointMake(targetSize.width/2, targetSize.height/2);
    }
    
    //确定origin.x
    CGPoint viewOrigin = CGPointZero;
    CGPoint anchorPosition = CGPointZero;
    if (targetCenter.x <= containerSize.width/2) {
        if (targetCenter.x - self.padding <= viewWidth/2) {
            //anchor无法居中，直接从左边开始布局
            viewOrigin.x = self.padding;
            anchorPosition.x = targetCenter.x - self.padding;
        } else {
            viewOrigin.x = targetCenter.x - viewWidth/2;
            anchorPosition.x = viewWidth/2;
        }
    } else {
        if (containerSize.width-targetCenter.x-self.padding <= viewWidth/2) {
            //anchor无法居中，直接从右边边开始布局
            viewOrigin.x = containerSize.width-viewWidth-self.padding;
            anchorPosition.x = viewWidth - (containerSize.width-targetCenter.x-self.padding);
        } else {
            viewOrigin.x = targetCenter.x - viewWidth/2;
            anchorPosition.x = viewWidth/2;
        }
    }
    
    CGPoint contentOrigin = CGPointZero;
    contentOrigin.x = self.padding * 2;
    contentOrigin.y = 0;
    //确定origin.y
    CGFloat targetHeight = targetView.bounds.size.height;
    if (targetCenter.y + targetHeight/2 + viewHeight >= containerSize.height) {
        self.anchorDirection = UCARPopTipViewAnchorDirectionDown;
        if (pointPosition == UCARPopTipViewAnchorPointPositionBoundary) {
            viewOrigin.y = targetCenter.y - targetHeight/2 - viewHeight;
        } else {
            viewOrigin.y = targetCenter.y - viewHeight;
        }
        anchorPosition.y = viewHeight;
    } else {
        self.anchorDirection = UCARPopTipViewAnchorDirectionUp;
        if (pointPosition == UCARPopTipViewAnchorPointPositionBoundary) {
            viewOrigin.y = targetCenter.y + targetHeight/2;
        } else {
            viewOrigin.y = targetCenter.y;
        }
        contentOrigin.y += self.anchorSize;
        anchorPosition.y = 0;
    }
    
    self.anchorPosition = anchorPosition;
    
    CGRect contentRect = CGRectZero;
    contentRect.origin = contentOrigin;
    contentRect.size = contentSize;
    contentView.frame = contentRect;
    
    CGRect viewRect = CGRectZero;
    viewRect.origin = viewOrigin;
    viewRect.size = CGSizeMake(viewWidth, viewHeight);
    self.contentView.frame = viewRect;
    
    [containerView bringSubviewToFront:self];
    
    [self maskLayer];
}

- (void)maskLayer
{
    //顺时针方向绘制
    CGSize size = self.contentView.bounds.size;
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (self.anchorDirection == UCARPopTipViewAnchorDirectionUp) {
        CGPoint anchor = self.anchorPosition;
        CGPoint anchorRight = CGPointMake(anchor.x + self.anchorSize, anchor.y + self.anchorSize);
        CGPoint anchorLeft = CGPointMake(anchor.x - self.anchorSize, anchor.y + self.anchorSize);
        
        CGPoint rightTop = CGPointMake(size.width, self.anchorSize);
        CGPoint rightTopArcBegin = CGPointMake(rightTop.x-self.arcRadius, rightTop.y);
        CGPoint rightTopCenter = CGPointMake(rightTop.x-self.arcRadius, rightTop.y+self.arcRadius);
        
        CGPoint rightBottom = CGPointMake(size.width, size.height);
        CGPoint rightBottomArcBegin = CGPointMake(rightBottom.x, rightBottom.y-self.arcRadius);
        CGPoint rightBottomCenter = CGPointMake(rightBottom.x-self.arcRadius, rightBottom.y-self.arcRadius);
        
        CGPoint leftBottom = CGPointMake(0, size.height);
        CGPoint leftBottomArcBegin = CGPointMake(leftBottom.x+self.arcRadius, leftBottom.y);
        CGPoint leftBottomCenter = CGPointMake(leftBottom.x+self.arcRadius, leftBottom.y-self.arcRadius);
        
        CGPoint leftTop = CGPointMake(0, self.anchorSize);
        CGPoint leftTopArcBegin = CGPointMake(leftTop.x, leftTop.y+self.arcRadius);
        CGPoint leftTopCenter = CGPointMake(leftTop.x+self.arcRadius, leftTop.y+self.arcRadius);
        
        [path moveToPoint:anchorLeft];
        [path addLineToPoint:anchor];
        [path addLineToPoint:anchorRight];
        [path addLineToPoint:rightTopArcBegin];
        [path addArcWithCenter:rightTopCenter radius:self.arcRadius startAngle:M_PI_2*3 endAngle:M_PI*2 clockwise:YES];
        [path addLineToPoint:rightBottomArcBegin];
        [path addArcWithCenter:rightBottomCenter radius:self.arcRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [path addLineToPoint:leftBottomArcBegin];
        [path addArcWithCenter:leftBottomCenter radius:self.arcRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [path addLineToPoint:leftTopArcBegin];
        [path addArcWithCenter:leftTopCenter radius:self.arcRadius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
        [path addLineToPoint:anchorLeft];
        [path closePath];
    } else {
        CGPoint anchor = self.anchorPosition;
        CGPoint anchorRight = CGPointMake(anchor.x + self.anchorSize, anchor.y - self.anchorSize);
        CGPoint anchorLeft = CGPointMake(anchor.x - self.anchorSize, anchor.y - self.anchorSize);
        
        CGPoint leftBottom = CGPointMake(0, size.height-self.anchorSize);
        CGPoint leftBottomArcBegin = CGPointMake(leftBottom.x+self.arcRadius, leftBottom.y);
        CGPoint leftBottomCenter = CGPointMake(leftBottom.x+self.arcRadius, leftBottom.y-self.arcRadius);
        
        CGPoint leftTop = CGPointMake(0, 0);
        CGPoint leftTopArcBegin = CGPointMake(leftTop.x, leftTop.y+self.arcRadius);
        CGPoint leftTopCenter = CGPointMake(leftTop.x+self.arcRadius, leftTop.y+self.arcRadius);
        
        CGPoint rightTop = CGPointMake(size.width, 0);
        CGPoint rightTopArcBegin = CGPointMake(rightTop.x-self.arcRadius, rightTop.y);
        CGPoint rightTopCenter = CGPointMake(rightTop.x-self.arcRadius, rightTop.y+self.arcRadius);
        
        CGPoint rightBottom = CGPointMake(size.width, size.height-self.anchorSize);
        CGPoint rightBottomArcBegin = CGPointMake(rightBottom.x, rightBottom.y-self.arcRadius);
        CGPoint rightBottomCenter = CGPointMake(rightBottom.x-self.arcRadius, rightBottom.y-self.arcRadius);
        
        [path moveToPoint:anchorRight];
        [path addLineToPoint:anchor];
        [path addLineToPoint:anchorLeft];
        [path addLineToPoint:leftBottomArcBegin];
        [path addArcWithCenter:leftBottomCenter radius:self.arcRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [path addLineToPoint:leftTopArcBegin];
        [path addArcWithCenter:leftTopCenter radius:self.arcRadius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
        [path addLineToPoint:rightTopArcBegin];
        [path addArcWithCenter:rightTopCenter radius:self.arcRadius startAngle:M_PI_2*3 endAngle:M_PI*2 clockwise:YES];
        [path addLineToPoint:rightBottomArcBegin];
        [path addArcWithCenter:rightBottomCenter radius:self.arcRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [path addLineToPoint:anchorRight];
        [path closePath];
    }
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    self.contentView.layer.mask = maskLayer;
    // 设置 position & position 目的是弄一个动画
    // [self setupPositionAndPnchorPoint];
}

// 设置 position & anchorPoint 目的是弄一个动画
- (void)setupPositionAndPnchorPoint {
    // contentView 的宽高
    CGFloat contentWith = self.contentView.frame.size.width;
    CGFloat contentHeight = self.contentView.frame.size.height;
    
    // 通过 self.anchorPosition 与 self.contentView.frame.origin 相加得到实际的相对三角的 layer.position.
    self.contentView.layer.position = CGPointMake(self.anchorPosition.x+self.contentView.frame.origin.x, self.anchorPosition.y+self.contentView.frame.origin.y);
    
    // 设置锚点
    self.contentView.layer.anchorPoint = CGPointMake(self.anchorPosition.x/contentWith, self.anchorPosition.y/contentHeight);
}

@end
