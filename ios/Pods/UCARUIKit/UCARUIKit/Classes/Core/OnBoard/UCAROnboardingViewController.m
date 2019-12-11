//
//  UCAROnboardingViewController.m
//  UCarDriver
//
//  Created by baotim on 16/9/7.
//  Copyright © 2016年 szzc. All rights reserved.
//

#import "UCAROnboardingViewController.h"
#import <AVFoundation/AVFoundation.h>

static CGFloat const kPageControlHeight = 35;
static NSString * const kSkipButtonText = @"跳过";

@interface UCAROnboardingViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

// View controllers and background image
@property (nonatomic, strong) NSArray                *viewControllers;
@property (nonatomic, strong) UIImage                *backgroundImage;

// Page Control
@property (nonatomic, strong) UIPageControl          *pageControl;
@property (nonatomic, strong) UIPageViewController   *pageViewController;

// Skip Button
@property (nonatomic, strong) UIButton               *skipButton;

// video player used when backgroud is video
@property (nonatomic, strong) AVPlayerLayer          *videoPlayer;
@property (nonatomic, strong) NSURL                  *videoURL;

//content view controller
@property (nonatomic, strong) UCAROnboardingContentViewController *currentPage;
@property (nonatomic, strong) UCAROnboardingContentViewController *upcomingPage;

@end

@implementation UCAROnboardingViewController

- (void)dealloc {
    self.pageViewController.delegate = nil;
    self.pageViewController.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - Initializing with images

+ (instancetype)onboardWithBackgroundImage:(UIImage *)backgroundImage contents:(NSArray *)contents {
    UCAROnboardingViewController *onboardingVC = [[self alloc] initWithBackgroundImage:backgroundImage contents:contents];
    return onboardingVC;
}

- (instancetype)initWithBackgroundImage:(UIImage *)backgroundImage contents:(NSArray *)contents {
    self = [self initWithContents:contents];
    
    self.backgroundImage = backgroundImage;
    
    return self;
}


#pragma mark - Initializing with video files

+ (instancetype)onboardWithBackgroundVideoURL:(NSURL *)backgroundVideoURL contents:(NSArray *)contents {
    UCAROnboardingViewController *onboardingVC = [[self alloc] initWithBackgroundVideoURL:backgroundVideoURL contents:contents];
    return onboardingVC;
}

- (instancetype)initWithBackgroundVideoURL:(NSURL *)backgroundVideoURL contents:(NSArray *)contents {
    self = [self initWithContents:contents];
    
    _videoURL = backgroundVideoURL;
    
    return self;
}

#pragma mark - Initialization

- (instancetype)initWithContents:(NSArray *)contents {
    self = [super init];
    
    self.viewControllers = contents;
    
    // set the default properties
    self.swipingEnabled = YES;
    self.hidePageControl = NO;
    self.enableBounce = NO;
    self.skipButtonFontSize = 14;
    self.skipButtonBackgroundColor = [UIColor clearColor];
    self.skipButtonTextColor = [UIColor whiteColor];
    self.skipButtonSize = CGSizeMake(40, 20);
    self.skipButtonLTCornerPoint = CGPointMake([UIScreen mainScreen].bounds.size.width - 60, 20);
    self.pageControlBottomPadding = 60;
    
    self.allowSkipping = NO;
    self.skipHandler = ^{};
    
    self.pageControl = [UIPageControl new];
    self.pageControl.numberOfPages = self.viewControllers.count;
    self.pageControl.userInteractionEnabled = NO;
    
    self.skipButton = [UIButton new];
    [self.skipButton setTitle:kSkipButtonText forState:UIControlStateNormal];
    [self.skipButton setBackgroundColor:self.skipButtonBackgroundColor];
    [self.skipButton addTarget:self action:@selector(handleSkipButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.skipButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    // create the movie player controller
    self.videoPlayer = [AVPlayerLayer new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self generateView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // if we have a video URL, start playing
    if (_videoURL && self.videoPlayer.player) {
        [self.videoPlayer.player play];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.automaticallyAdjustsScrollViewInsets = YES;
    if (_videoURL && self.videoPlayer.player) {
        [self.videoPlayer.player setRate:0.0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)generateView
{
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageViewController.view.frame = self.view.frame;
    _pageViewController.view.backgroundColor = [UIColor whiteColor];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self.swipingEnabled ? self : nil;
    
    if (!self.enableBounce) {
        for (id scrollView in _pageViewController.view.subviews) {
            if ([scrollView isKindOfClass:[UIScrollView class]]) {
                ((UIScrollView *)scrollView).delegate = self;
            }
        }
    }
    
    UIImageView *backgroundImageView = nil;
    if (self.backgroundImage) {
        backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [backgroundImageView setImage:self.backgroundImage];
        [self.view addSubview:backgroundImageView];
    }

    for (UCAROnboardingContentViewController *contentVC in self.viewControllers) {
        contentVC.delegate = self;
    }
    
    _currentPage = [self.viewControllers firstObject];
    
    [_pageViewController setViewControllers:@[_currentPage] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    _pageViewController.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    
    // send the background image view to the back if we have one
    if (backgroundImageView) {
        [_pageViewController.view sendSubviewToBack:backgroundImageView];
    }
    
    // otherwise send the video view to the back if we have one
    else if (_videoURL) {
        AVPlayer *player = [AVPlayer playerWithURL:_videoURL];
        self.videoPlayer.player = player;
        self.videoPlayer.frame = self.view.bounds;
        self.videoPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        [_pageViewController.view.layer addSublayer:self.videoPlayer];
    }
    
    // create and configure the page control
    if (!self.hidePageControl && self.viewControllers.count > 1) {
        self.pageControl.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame) - self.pageControlBottomPadding - kPageControlHeight, self.view.frame.size.width, kPageControlHeight);
        [self.view addSubview:self.pageControl];
    }
    
    // if we allow skipping, setup the skip button
    if (self.allowSkipping) {
        self.skipButton.frame = CGRectMake(self.skipButtonLTCornerPoint.x, self.skipButtonLTCornerPoint.y, self.skipButtonSize.width, self.skipButtonSize.height);
        if (self.skipButtonBackgroundImage) {
            [self.skipButton setBackgroundImage:self.skipButtonBackgroundImage forState:UIControlStateNormal];
            [self.skipButton setTitle:@"" forState:UIControlStateNormal];
        }
        if (self.skipButtonBackgroundColor) {
            [self.skipButton setBackgroundColor:self.skipButtonBackgroundColor];
        }
        if (self.skipButtonTextColor) {
            [self.skipButton setTitleColor:self.skipButtonTextColor forState:UIControlStateNormal];
        }
        if (self.skipButtonFontSize > 0) {
            self.skipButton.titleLabel.font = [UIFont systemFontOfSize:self.skipButtonFontSize];
        }
        
        [self.view addSubview:self.skipButton];
    }
}

- (void)handleAppEnteredForeground
{
    if (_videoURL && self.videoPlayer.player) {
        [self.videoPlayer.player play];
    }
}

#pragma mark - Skipping

- (void)handleSkipButtonPressed
{
    if (self.skipHandler) {
        self.skipHandler();
    }
    _videoURL = nil;
    for (UCAROnboardingContentViewController *contentVC in self.viewControllers) {
        [contentVC stopVideoPlay];
        contentVC.videoURL = nil;
    }
}

#pragma mark - Page view controller data source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    if (viewController == [self.viewControllers firstObject]) {
        return nil;
    }
    else {
        NSInteger priorPageIndex = [self.viewControllers indexOfObject:viewController] - 1;
        return self.viewControllers[priorPageIndex];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    if (viewController == [self.viewControllers lastObject]) {
        return nil;
    }
    else {
        NSInteger nextPageIndex = [_viewControllers indexOfObject:viewController] + 1;
        return self.viewControllers[nextPageIndex];
    }
}


#pragma mark - Page view controller delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {

    if (!completed) {
        return;
    }
    
    UIViewController *viewController = [pageViewController.viewControllers lastObject];
    NSInteger newIndex = [self.viewControllers indexOfObject:viewController];
    [self.pageControl setCurrentPage:newIndex];
}

- (void)moveNextPage {
    NSUInteger indexOfNextPage = [self.viewControllers indexOfObject:_currentPage] + 1;
    
    if (indexOfNextPage < self.viewControllers.count) {
        [self.pageViewController setViewControllers:@[self.viewControllers[indexOfNextPage]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        [self.pageControl setCurrentPage:indexOfNextPage];
    }
}


#pragma mark - Page scroll status

- (void)setCurrentPage:(UCAROnboardingContentViewController *)currentPage {
    _currentPage = currentPage;
}

- (void)setNextPage:(UCAROnboardingContentViewController *)nextPage {
    _upcomingPage = nextPage;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
 
    if ([self.currentPage isEqual:[self.viewControllers firstObject]] && scrollView.contentOffset.x < scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    } else if ([self.currentPage isEqual:[self.viewControllers lastObject]]
               && scrollView.contentOffset.x > scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
        if (self.isSwipeSkip) {
            [self.currentPage handleButtonPressed];
        }

    }
//    CGFloat percentComplete = fabs(scrollView.contentOffset.x - self.view.frame.size.width) / self.view.frame.size.width;
//    CGFloat percentCompleteInverse = 1.0 - percentComplete;
//    
//    if (_upcomingPage == _currentPage || percentComplete == 0) {
//        return;
//    }
//    
//    [_upcomingPage updateAlphas:percentComplete];
//    
//    [_currentPage updateAlphas:percentCompleteInverse];
//    
//    // determine if we're transitioning to or from our last page
//    BOOL transitioningToLastPage = (_upcomingPage == self.viewControllers.lastObject);
//    BOOL transitioningFromLastPage = (_currentPage == self.viewControllers.lastObject) && (_upcomingPage == self.viewControllers[self.viewControllers.count - 2]);
//    
//    
//    // fade the skip button to and from the last page
//    if (self.fadeSkipButtonOnLastPage) {
//        if (transitioningToLastPage) {
//            _skipButton.alpha = percentCompleteInverse;
//        }
//        
//        else if (transitioningFromLastPage) {
//            _skipButton.alpha = percentComplete;
//        }
//    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.currentPage isEqual:[self.viewControllers firstObject]] && scrollView.contentOffset.x < scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    } else if ([self.currentPage isEqual:[self.viewControllers lastObject]]
               && scrollView.contentOffset.x > scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
}

@end
