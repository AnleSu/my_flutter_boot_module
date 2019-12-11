UCARRobot

```
0.1.5   设置测试环境模块-自定义测试界面
0.1.9   设置流量监控模块-HTTP返回数据Content解密
0.2.4   主图标更改到右边位置、移除 UITextView+Placeholder
```


## Installation
To install it, simply add the following line to your Podfile:
1、cocoapods依赖

```
pod 'UCARRobot', :configurations => ['Debug'] #必选
pod 'UCARRobot/WithLogger', :configurations => ['Debug'] #可选 日志是基于CocoaLumberjack
```

2.UCAR内部接入 参考:
```
//==========AppDelegate 接入, setEnvClass 设置原先已有的调试界面类
- (void)initRobot{
#ifdef DEBUG
[UCARRobot install];
[UCARRobot setEnvClass:[UCARDebugViewController class]];//设置自定义切换环境界面
[UCARRobot setHTTPContentDecrypt:^NSDictionary * (NSDictionary * _Nullable data) {//设置HttpResponse解密content
    return [[UCARTravelHttpClient sharedClient] decryptResponse:data];
}];
#endif
}

//=========自定义环境切换界面 需要返回关闭Robot 可以重载一下返回按钮方法

#ifdef DEBUG
#import <UCARRobot.h>
#endif

- (void)backPreViewController {
    [super backPreViewController];
    #ifdef DEBUG
    if (NSClassFromString(@"UCARRobot")) {
    [UCARRobot closeWindow];
}
#endif
}

```

<p align="center">
<img src="Image/1_DecryptContent.png" alt="Sample"  width="320" height="568">
</p>


```
content 之前加密的。通过上面 setHTTPContentDecrypt来做解密
不同的项目, 设置对应的 网络请求 Class
[UCARApp]: UCARTravelHttpClient
[CMT]: UCARCMTransitHttpClient
[Driver]: UCARDriverHttpClient
[WCC]: WCCHttpManager
[YCC]: YCCHttpManager
[YY]: UCARYYHttpClient
```






## Author

zhiqiu.su@ucarinc.com

## License

UCARRobot is available under the MIT license. See the LICENSE file for more info.
