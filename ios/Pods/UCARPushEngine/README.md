使用说明
========

安装
----

``` {.sourceCode .ruby}
pod 'UCARPushEngine'
```

初始化
------

### 前置依赖

网络库初始化之前必须先初始化环境变量，即初始化 **UCAREnvConfig** 。

注： **UCAREnvConfig** 位于 UCARUtility 库中。

### 必要参数

1.  appVersion

App版本号，一般为 业务线编码 + 版本，如"700100"。

2.  sysName

业务名称，具体可参见
<http://wiki.10101111.com/pages/viewpage.action?pageId=15532553>

3.  pushTypeIsBusinessType

pushType的解析位置。

为YES，则直接解析businessType；为NO，则从UCARPushReceiveHandler的dict中解析，key值为pushType。

### 示例

``` {.sourceCode .objc}
[UCAREnvConfig initWithConfigFileName:@"info" envKey:UCAREnvDev1];    
[UCARPushService sharedService].appVersion = @"910271";
[UCARPushService sharedService].sysName = @"ucar";
NSString *deviceID = @"v2.drivercar_c2c_IOS_5c9a830754d45916e80475f71e88548c58202e73522bc10a87f0e75f898797fb_36774";
[[UCARPushService sharedService] startServiceWithDeviceID:deviceID];
```

注册及移除
----------

``` {.sourceCode .objc}
- (void)viewDidLoad {
    [super viewDidLoad];

    __weak UCARViewController *weakSelf = self;
    [[UCARPushService sharedService] registerPushService:self forPushType:UCARPushTypeSomething responseHandler:^(NSInteger pushType, NSDictionary * _Nonnull dict, NSString * _Nonnull UUID) {
        weakSelf.count = weakSelf.count + 1;
    }];
}
- (void)dealloc {
    [[UCARPushService sharedService] unregisterPushService:self];
}
```
