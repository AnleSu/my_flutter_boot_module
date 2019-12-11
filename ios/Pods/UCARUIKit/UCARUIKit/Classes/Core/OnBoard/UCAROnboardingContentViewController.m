//
//  UCAROnboardingContentViewController.m
//  UCarDriver
//
//  Created by baotim on 16/9/7.
//  Copyright © 2016年 szzc. All rights reserved.
//

#import "UCAROnboardingContentViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UCAROnboardingViewController.h"

@interface UCAROnboardingContentViewController ()

@property (nonatomic, strong) UIImage       *backgroundImage;
@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, strong) UIButton      *actionButton;
@property (nonatomic, strong) NSString      *buttonText;

@property (nonatomic, strong) AVPlayerLayer *videoPlayer;

@property (nonatomic, strong) dispatch_block_t actionHandler; //按钮回调

@end

@implementation UCAROnboardingContentViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_videoPlayer.player.currentItem];
}

// Initializes
+ (instancetype)contentWithImage:(UIImage *)image buttonText:(NSString *)buttonText action:(dispatch_block_t)action
{
    UCAROnboardingContentViewController* contentVC = [[self alloc] initWithImage:image buttonText:buttonText action:action];
    return contentVC;
}

- (instancetype)initWithImage:(UIImage *)image buttonText:(NSString *)buttonText action:(dispatch_block_t)action
{
    return [self initWithImage:image videoURL:nil buttonText:buttonText action:action];
}

+ (instancetype)contentWithVideoURL:(NSURL *)videoURL buttonText:(NSString *)buttonText action:(dispatch_block_t)action
{
    UCAROnboardingContentViewController* contentVC = [[self alloc] initWithVideoURL:videoURL buttonText:buttonText action:action];
    return contentVC;
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL buttonText:(NSString *)buttonText action:(dispatch_block_t)action
{
    return [self initWithImage:nil videoURL:videoURL buttonText:buttonText action:action];
}

- (instancetype)initWithImage:(UIImage *)image videoURL:videoURL buttonText:(NSString *)buttonText action:(dispatch_block_t)action
{
    self = [super init];
    
    _backgroundImage = image;
    _buttonText = buttonText;
    _videoURL = videoURL;
    _actionHandler = action;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    return self;
}

- (void)handleAppEnteredForeground
{
    if (_videoURL && self.videoPlayer.player) {
        [self.videoPlayer.player play];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // now that the view has loaded we can generate the content
    
    [self generateView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // if we have a delegate set, mark ourselves as the next page now that we're
    // about to appear
    if (self.delegate) {
        [self.delegate setNextPage:self];
    }
    
    // if we have a video, start playing
    if (_videoURL && self.videoPlayer) {
        [self.videoPlayer.player play];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // if we have a delegate set, mark ourselves as the current page now that
    // we've appeared
    if (self.delegate) {
        [self.delegate setCurrentPage:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopVideoPlay];
}

- (void)generateView
{
    self.view.backgroundColor = [UIColor clearColor];
    
    if (_backgroundImage) {
        
        _imageView = [[UIImageView alloc] initWithImage:_backgroundImage];
        [_imageView setFrame:self.view.bounds];
        [self.view addSubview:_imageView];
        
    } else if (self.videoURL) {
        
        //使用playerItem获取视频的信息，当前播放时间，总时间等
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:_videoURL];
        //player是视频播放的控制器，可以用来快进播放，暂停等
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        self.videoPlayer = [AVPlayerLayer playerLayerWithPlayer:player];
        self.videoPlayer.frame = self.view.bounds;
        self.videoPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        [self.view.layer addSublayer:self.videoPlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
    }
    
    if (_buttonText) {
        _actionButton = [[UIButton alloc] initWithFrame:CGRectMake(self.actionButtonLTCornerPoint.x, self.actionButtonLTCornerPoint.y, self.actionButtonSize.width, self.actionButtonSize.height)];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:self.actionButtonFontSize];
        [_actionButton setTitle:_buttonText forState:UIControlStateNormal];
        if (self.actionButtonTextColor) {
            [_actionButton setTitleColor:self.actionButtonTextColor forState:UIControlStateNormal];
        }
        if (self.actionButtonBackgroundImage) {
            [_actionButton setBackgroundImage:self.actionButtonBackgroundImage forState:UIControlStateNormal];
        }
        
        [_actionButton addTarget:self action:@selector(handleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_actionButton];
    }
}

#pragma mark - action button callback

- (void)handleButtonPressed
{
    if (_actionHandler) {
        _actionHandler();
    }
    _videoURL = nil;
}

#pragma mark - Transition alpha

- (void)updateAlphas:(CGFloat)newAlpha
{
    _imageView.alpha = newAlpha;
    _actionButton.alpha = newAlpha;
}

- (void)stopVideoPlay
{
    if (_videoURL && self.videoPlayer) {
        [self.videoPlayer.player setRate:0.0];
    }
}

#pragma mark - Notification
- (void)moviePlayDidEnd:(NSNotification*)notification{
    //视频播放完成
    if (_actionHandler) {
        _actionHandler();
    }
    _videoURL = nil;
}

@end
