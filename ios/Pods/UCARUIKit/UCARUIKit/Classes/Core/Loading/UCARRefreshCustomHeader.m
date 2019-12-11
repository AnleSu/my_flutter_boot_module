//
//  UCARRefreshCustomHeader.m
//  UCARUIKit
//
//  Created by linux on 01/03/2018.
//

#import "UCARRefreshCustomHeader.h"
#import "UCARPullLoadingViewProtocol.h"
#import "UCARUIKitConfigInstance.h"

@interface UCARRefreshCustomHeader ()

@property (nonatomic, strong) UIView<UCARPullLoadingViewProtocol> *loadingView;

@end

@implementation UCARRefreshCustomHeader

- (UIView<UCARPullLoadingViewProtocol> *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UCARUIKitConfigInstance sharedConfig].dataSource pullLoadingView];
    }
    return _loadingView;
}

- (void)prepare
{
    [super prepare];
    [self addSubview:self.loadingView];
}

//layout
- (void)placeSubviews
{
    [super placeSubviews];
    self.loadingView.center = CGPointMake(self.mj_w/2, self.mj_h/2);
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshState oldState = self.state;
    if (state == oldState) return;
    [super setState:state];
    
    self.loadingView.scrollView = self.scrollView;
    
    if (state == MJRefreshStateIdle) {
        [self.loadingView loadingFinished];
    } else if (state == MJRefreshStatePulling) {
        [self.loadingView loadingFinished];
    } else if (state == MJRefreshStateRefreshing) {
        [self.loadingView loading];
    }
}

@end
