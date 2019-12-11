# ucarsharesdk

### 一、集成到项目
主要有两个 pod 库：  
```
pod 'UCARSetSDK'  
pod 'UCARShareSDK'
```  
其中 `UCARSetSDK` 是第三方 SDK 的集合，可随意组合。  `UCARShareSDK` 是核心的分享功能，可随意组合。将其分成两个 pod 的原因是便于单独的升级互相不受影响。尤其是 `WechatSDK` 在支付封装的时候也能共用。 
同时将 `UCARMethodScheduler` 放于 `UCARSetSDK` 的目的是可以在支付模块封装的时候共用。

![Architecture](./Resource/Architecture.png)   
由上图也可以看出：`UCARShareSDK` 依赖于 `UCARSetSDK`，没有耦合。

代码结构预览：  
![CodeArchitecture](./Resource/CodeArchitecture.png)  

### 二、使用
#### 2.1 注册
```
// 注册
NSArray *activePlatforms = @[@(UCARShareTypeWeChatSession), @(UCARShareTypeQQSession), @(UCARShareTypeSina)];
[UCARShareSDK registerActivePlatforms:activePlatforms onConfiguration:^(UCARShareType shareType, UCARSDKSetupTools *setupTools) {
    switch (shareType) {
            case UCARShareTypeWeChatSession:
        {
            [setupTools UCARSDKSetupWeChatByAppId:kWXAppID];
        }
            break;
            case UCARShareTypeQQSession:
        {
            [setupTools UCARSDKSetupQQByAppId:kQQAppID];
        }
            break;
            case UCARShareTypeSina:
        {
            [setupTools UCARSDKSetupSinaWeiboByAppKey:kSinaAppKey redirectUri:kSinaCallback];
        }
            break;
            
        default:
            break;
    }
}];
```  

#### 2.2 回调处理
需要加上在 `-[UCARPlatformContext handleOpenURL:]` 中  `[UCARShareSDK handleOpenURL:url];`.

```
// handleOpenURL
- (BOOL)handleOpenURL:(NSURL *)url {
    // TODO: 项目中正常的处理
    
    // 可能是分享功能回调
    [UCARShareSDK handleOpenURL:url];
    
    return YES;
}
```  

#### 2.3 发起分享
先声明一个实例：  
```
@property (nonatomic, strong) UCARShareSDK *shareSDK;
```  

发起分享，以新浪为例：  
```  
// 新浪
- (void)sina {
    UCARShareItem *item = [self itemWithShareType:UCARShareTypeSina];
    [self.shareSDK shareSDKWithItem:item];
}

// 通过 shareType 获取一个实例
- (UCARShareItem*)itemWithShareType:(UCARShareType)shareType {
    UCARShareItem *item = [UCARShareItem itemWithShareType:shareType];
    
    item.title = @"个人中心--邀请有礼分享文案--标题全国新老";
    item.summary = @"个人中心--邀请有礼分享文案--标题全国新老";
    item.webpageUrl = @"http://mtest.10101111.com/html5/redpackets/20190226/newmember/open.html?key=UnhlL3Rwd2pDblhmaTBFcFozZHAydz09";
    item.thumbnaiURL = @"https://img01test.10101111.com/adpos/share/2016/12/06/promotion20161206201734337.jpg";
    
    return item;
}
```  

关于打开/分享小程序:  
```
// 打开微信小程序
- (void)openwxxcx {
    UCARShareItem *item = [UCARShareItem itemWithShareType:UCARShareTypeOpenMiniProgram];
    // 拉起的小程序的username
    item.userName = @"gh_cd9eff690004";
    // 拉起小程序页面的可带参路径，不填默认拉起小程序首页
    item.path = @"pages/home/home";
    
    // 打开小程序
    [self.shareSDK shareSDKWithItem:item];
}

// 分享微信小程序
- (void)sharewxxcx {
    UCARShareItem *item = [UCARShareItem itemWithShareType:UCARShareTypeMiniProgram];
    // 打开的小程序的 username
    item.userName = @"gh_cd9eff690004";
    // 打开小程序页面的可带参路径，不填默认打开小程序首页
    item.path = @"pages/home/home";
    item.title = @"小程序标题";
    item.summary = @"小程序描述";
    item.webpageUrl = @"http://mtest.10101111.com/html5/redpackets/20190226/newmember/open.html?key=UnhlL3Rwd2pDblhmaTBFcFozZHAydz09";
    
    // 把小程序分享给微信好友
    [self.shareSDK shareSDKWithItem:item];
}
```

图片分享到微信:  
```
// 分享文档到微信
- (UCARShareItem*)itemImageWithShareType:(UCARShareType)shareType {
    UCARShareItem *item = [UCARShareItem itemWithShareType:shareType];
    
    item.summary = @"个人中心--邀请有礼分享文案--标题全国新老";
    
    // 实际分享的图片数据
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res1" ofType:@"jpg"];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    item.imageData = imageData;
    
    // 不能超过 64 k
    UIImage *thumbImage = [UIImage imageNamed:@"res1thumb.png"];
    item.thumbImage = thumbImage;
    
    return item;
}
```

文档分享到微信：  
```
// 文档微信
- (void)wxFileWithRow:(NSUInteger)row {
    UCARShareItem * item = nil;
    if (row == 0) {
        item = [self itemFileWithShareType:UCARShareTypeWeChatSession];
    } else {
        item = [self itemFileWithShareType:UCARShareTypeWechatTimeline];
    }
    
    [self.shareSDK shareSDKWithItem:item];
}

// 分享文档到微信
- (UCARShareItem*)itemFileWithShareType:(UCARShareType)shareType {
    UCARShareItem *item = [UCARShareItem itemWithShareType:shareType];
    
    item.title = @"个人中心--邀请有礼分享文案--标题全国新老";
    item.summary = @"个人中心--邀请有礼分享文案--标题全国新老";
    
    item.thumbImage = [UIImage imageNamed:@"res2.jpg"];
    item.fileExtension = @"pdf";
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"iphone4" ofType:@"pdf"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    item.fileData = fileData;
    
    return item;
}
```

目前仅支持分享到好友，不支持分享到朋友圈。官方的例子也不能.....

#### 2.4 代理 <UCARShareSDKDelegate>
```
#pragma mark -
#pragma mark - UCARShareSDKDelegate
- (void)shareSDK:(UCARShareSDK *)shareSDK result:(UCARShareSDKResult)result message:(NSString *)message {
    NSLog(@"%@", message);
}
```  

状态的定义：  
```
// 结果状态返回
typedef NS_ENUM(NSInteger, UCARShareSDKResult) {
    UCARShareSDKResultSuccess,
    UCARShareSDKResultFail,
    UCARShareSDKResultCancel
};
```

使用方法, 请见 `HomeViewController` 文件。
