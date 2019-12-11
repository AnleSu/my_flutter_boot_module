//
//  UCARPullLoadingViewProtocol.h
//  UCARUIKit
//
//  Created by linux on 28/02/2018.
//

#ifndef UCARPullLodingViewProtocol_h
#define UCARPullLodingViewProtocol_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol UCARPullLoadingViewProtocol <NSObject>

@property (weak, nonatomic) UIScrollView *scrollView;

//拉多少距离转一周
@property (nonatomic, assign) CGFloat distanceForTurnOneCycle;

- (void)loading;
//when cancel || finish loading, call this
- (void)loadingFinished;

@end


#endif /* UCARPullLodingViewProtocol_h */
