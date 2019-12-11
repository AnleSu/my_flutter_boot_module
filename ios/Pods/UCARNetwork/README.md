使用说明
========

安装
----

基于目前的封装方式，各业务线可直接使用各自的子spec进行集成。

``` {.sourceCode .ruby}
pod 'UCARNetwork/WCC'
```

初始化
------

### 前置依赖

网络库初始化之前必须先初始化环境变量，即初始化 **UCAREnvConfig** 。

注： **UCAREnvConfig** 位于 UCARUtility 库中。

### 必要参数

1.  cid

API版本号，一般为 业务线编码 + 版本，如"700100"。

2.  requestDelegate

请求事件代理，用于App层统一处理请求成功和失败的通用逻辑。

### 关于refreshKey

建议在 httpClient
初始化之后立刻调用。因为该请求用于和后台协商密钥，协商成功之前不会与后台进行任何通信。

### 示例

``` {.sourceCode .objc}
[UCAREnvConfig initWithConfigFileName:@"info" envKey:UCAREnvDev1];
[YCCHttpManager sharedClient].requestDelegate = self;
[[YCCHttpManager sharedClient] setCid:@"700100"];vs
[[YCCHttpManager sharedClient] refreshKey:YES];
```

内部统计的一些事件
------------------

httpError 所有请求错误（含业务错误）

MY\_RSA\_Fail 动态密钥RSA失败

MY\_my 上传密钥

MY\_dtmy 动态密钥

MY\_jtmy 静态密钥

requestDuration 请求时长

netChange 网络状态变化
