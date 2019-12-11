//
//  UCARWebViewBridgeController.m
//  UCARJSBridge
//
//  Created by linux on 27/12/2017.
//  Copyright © 2017 UCar. All rights reserved.
//

#import "UCARWebViewBridgeController.h"
#import "UCARJSBridgeDelegate.h"
#import "UCARWebViewBridgeConstants.h"
#import <WebKit/WebKit.h>

#import "UCARWebViewBridgeLoader.h"
#import "Masonry.h"

@interface UCARWebViewBridgeController () <WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate, UCARJSBridgeDelegate>

@property (nonatomic) WKWebView *webView;
@property (nonatomic) WKWebViewJavascriptBridge *webViewBridge;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) CGPoint currentOffset;

@end

@implementation UCARWebViewBridgeController

- (WKWebView *)webView
{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.delegate = self;
    }
    return _webView;
}

- (WKWebViewJavascriptBridge *)webViewBridge
{
    if (!_webViewBridge) {
        _webViewBridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
        [_webViewBridge setWebViewDelegate:self];
        
    }
    return _webViewBridge;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _parameters = @{};
        _routeType = UCARWebViewBridgeRouteTypeNone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.hidden = YES;
    [self initWebView];
    [self setCustomUserAgent:self.webView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
    self.isShow = YES;
    
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).mas_offset(-keyboardRect.size.height);
    }];
    
    [UIView animateWithDuration:duration.doubleValue animations:^{
        [self.view layoutIfNeeded];
    }];
}

//当键盘退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification {
    self.isShow = NO;
    
    [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
}

- (void)setCustomUserAgent:(WKWebView *)webView {
    // subclass overwrite the method.
}

- (void)initWebView{
    if (@available(iOS 11.0, *)) {
        // iOS > 11.0 全屏显示
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // iOS < 11.0 全屏显示
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
//    [WKWebViewJavascriptBridge enableLogging];
    
    [self registerHandlers];

    /**
     如果先addSubview，再loadWebView，则会引起
     Could not signal service com.apple.WebKit.WebContent: 113: Could not find specified service
     wtf ?
     */
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
}

- (void)registerHandlers
{
    __weak typeof(self) weakSelf = self;
    [self.webViewBridge registerHandler:UCARWebviewBridgeUCARJSCallNative handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf parseHandleData:data callback:responseCallback];
    }];
}

- (void)callHandler:(NSDictionary *)params callback:(WVJBResponseCallback)callback
{
    [self.webViewBridge callHandler:UCARWebviewBridgeUCARNativeCallJS data:params responseCallback:callback];
}

- (void)reloadWebView
{
    if (self.routeType == UCARWebViewBridgeRouteTypeNone) {
        NSURL *url = [[NSURL alloc] initWithString:self.webViewPagePath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [self.webView loadRequest:request];
    } else if (self.routeType == UCARWebViewBridgeRouteTypeApp) {
        // 未来参考YCC项目补充
    } else if (self.routeType == UCARWebViewBridgeRouteTypeHybrid) {
        // 未来参考YCC项目补充
    }
}

- (NSString *)convertParametersToJSON
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.parameters options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

//==============WKWebView delegate===================
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString *path= navigationAction.request.URL.scheme;
    NSString *newPath = [path lowercaseString];
    if ([newPath hasPrefix:@"sms"] || [newPath hasPrefix:@"tel"]) {
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:navigationAction.request.URL]) {
            [app openURL:navigationAction.request.URL];
            decisionHandler(WKNavigationActionPolicyCancel);
        }

    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self showLoading];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self dismissLoading];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self dismissLoading];
    [self webViewLoadFail];
    NSLog(@"didFailProvisionalNavigation %@", error);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self dismissLoading];
    [self webViewLoadFail];
    NSLog(@"didFailNavigation %@", error);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isShow == YES) {
        scrollView.contentOffset = self.currentOffset;
        self.isShow = NO;
    } else {
        self.currentOffset = scrollView.contentOffset;
    }
}

#pragma mark - private method
//子类在加载h5页时如果需要显示loading实现方法
- (void)showLoading
{
    // subclass overwrite the method.
}

- (void)dismissLoading
{
    // subclass overwrite the method.
}

//加载h5页失败
- (void)webViewLoadFail
{
    // subclass overwrite the method.
}

//=============JS Call Native==================
- (void)parseHandleData:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    NSString *protocol = data[UCARWebviewBridgeRequestKeyProtocol];
    if ([protocol isEqualToString:UCARWebviewBridgeProtocolHttp]) {
        [self callNativeHttp:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolMonitor]) {
        [self callNativeMonitor:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolRoute]) {
        [self callNativeRoute:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolRoutePop]) {
        [self callNativeRoutePop:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolRouteHome]) {
        [self callNativeRouteHome:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolStorage]) {
        [self callNativeStorage:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolAlbum]) {
        [self callNativeAlbum:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolLocation]) {
        [self callNativeLocation:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolGallery]) {
        [self callNativeGallery:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolDeviceId]) {
        [self callNativeDeviceId:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolCheckLogin]) {
        [self callNativeCheckLogin:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolLogin]) {
        [self callNativeLogin:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolShowQRCode]) {
        [self callNativeShowQRCode:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolShare]) {
        [self callNativeShare:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolNewShare]) {
        [self callNativeNewShare:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolShowPay]) {
        [self callNativePay:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolNewShowPay]) {
        [self callNativeNewPay:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolShowAddressBook]) {
        [self callNativeAddressBook:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolGetUid]) {
        [self callNativeUid:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolWechatDonate]) {
        [self callNativeWechatDonate:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolUpdateUI]) {
        [self callNativeUpdateUI:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolFaceRecognition]) {
        [self callNativeFaceRecognition:data callback:callback];
    } else if ([protocol isEqualToString:UCARWebviewBridgeProtocolNextStep]) {
        [self callNativeNextStep:data callback:callback];
    }
    else {
        callback(data);
    }
}

- (void)callNativeRoute:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    NSDictionary *parameters = data[UCARWebviewBridgeRequestKeyParameters];
    NSString *page = parameters[@"page"];
    NSURL *pageURL = [NSURL URLWithString:page];
    //根据host来区分
    NSString *host = pageURL.host;
    if ([host isEqualToString:UCARWebviewBridgeProtocolRouteHostWebView]) {
        NSString *pagePath = pageURL.path;
        if (pageURL.query.length > 0) {
            pagePath = [NSString stringWithFormat:@"%@?%@", pageURL.path, pageURL.query];
        }
        BOOL current = [parameters[@"current"] boolValue];
        if (current) {
            self.routeType = UCARWebViewBridgeRouteTypeHybrid;
            self.webViewPagePath = pagePath;
            [self reloadWebView];
        } else {
            UCARWebViewBridgeController *webViewVC = [[UCARWebViewBridgeController alloc] init];
            webViewVC.routeType = UCARWebViewBridgeRouteTypeHybrid;
            webViewVC.webViewPagePath = pagePath;
            [self.navigationController pushViewController:webViewVC animated:YES];
        }
        
        callback([self successResponse]);
    }
}

- (void)callNativeRoutePop:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    [self.navigationController popViewControllerAnimated:YES];
    callback([self successResponse]);
}

- (void)callNativeHttp:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeMonitor:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeRouteHome:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeStorage:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeAlbum:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeLocation:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeGallery:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeDeviceId:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeCheckLogin:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeLogin:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeShowQRCode:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeShare:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeNewShare:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativePay:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeNewPay:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeUid:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeAddressBook:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeWechatDonate:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeFaceRecognition:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

- (void)callNativeNextStep:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    // subclass overwrite the method.
}

//WKWebView是通过绑定内置ScrollView的滚动回调来刷新WKContentView内需要渲染的web内容的，从列表内容页回到列表页不会调WKContentView的刷新方法，导致出现h5内容显示不全。目前先采用手动滚动1像素使WKContentView内容刷新出来
- (void)callNativeUpdateUI:(NSDictionary *)data callback:(WVJBResponseCallback)callback
{
    CGPoint point = self.webView.scrollView.contentOffset;
    [self.webView.scrollView setContentOffset:CGPointMake(point.x, point.y + 1)];
}

//=============Native Call JS==================
- (void)callJSPush:(NSDictionary *)data
{
//     subclass overwrite the method.
//    NSDictionary *parameters = @{@"type": @"refresh",
//                                 @"data": @"who care"};
//    NSMutableDictionary *pushObj = [self requestDictForProtocol:UCARWebviewBridgeProtocolPush];
//    pushObj[UCARWebviewBridgeRequestKeyParameters] = parameters;
//        [self callHandler:pushObj callback:^(NSDictionary *responseData) {
//            NSLog(@"%@", responseData);
//        }];
}

- (void)callJSReloadCurrentPage
{
    //     subclass overwrite the method.
}

- (void)callJSPayResult
{
    //     subclass overwrite the method.
}

- (void)callJSFaceRecognitionResult
{
    //     subclass overwrite the method.
}

- (NSMutableDictionary *)requestDictForProtocol:(NSString *)protocol
{
    //为完整展示协议，此处先占位parameters段
    NSDictionary *request = @{UCARWebviewBridgeRequestKeyProtocol: protocol,
                              UCARWebviewBridgeRequestKeyParameters: @{}};
    return [request mutableCopy];
}

- (NSMutableDictionary *)successResponse
{
    NSDictionary *status = @{UCARWebviewBridgeResponseKeySuccess: @YES,
                             UCARWebviewBridgeResponseKeyError: @{}};
    //为完整展示协议，此处先占位data段
    NSDictionary *response = @{UCARWebviewBridgeResponseKeyStatus: status,
                               UCARWebviewBridgeResponseKeyData: @{}};
    return [response mutableCopy];
}

- (NSMutableDictionary *)failResponse
{
    NSDictionary *status = @{UCARWebviewBridgeResponseKeySuccess: @NO,
                             UCARWebviewBridgeResponseKeyError: @{}};
    //为完整展示协议，此处先占位data段
    NSDictionary *response = @{UCARWebviewBridgeResponseKeyStatus: status,
                               UCARWebviewBridgeResponseKeyData: @{}};
    return [response mutableCopy];
}

- (NSString *)fixHybridStoreKey:(NSString *)key
{
    return [@"UCARHybrid_" stringByAppendingString:key];
}

@end
