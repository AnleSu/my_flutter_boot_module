# 使用说明

## 安装

基本服务

```ruby
pod 'UCARMonitor'
```

带Crash监测

```ruby
pod 'UCARMonitor/Crash'
```

## 初始化

### 前置依赖

初始化之前必须先初始化环境变量，即初始化 **UCAREnvConfig** 。

注： **UCAREnvConfig** 位于 UCARUtility 库中。

### 必要参数

#### UCARMonitorStore

1. version

版本：新/旧。该属性需要在存储事件之前设置，会影响最终的数据格式。

#### UCARMonitorNewStore

1. appVersion

App版本号，一般为 业务线编码 + 版本，如“700100”。

2. userID

用户ID。

3. appName

app编码，使用UCARMonitorAppName枚举值。

4. mobile

手机号

#### UCARMonitorOldStore

1. userType

司机端/客户端

2. appVersion

App版本号，一般为 业务线编码 + 版本，如“700100”。

3. userID

用户ID。该值为合成值，依赖userID和手机号

### 示例

```objc
[UCAREnvConfig initWithConfigFileName:@"info" envKey:UCAREnvDev1];
[UCARMonitorStore sharedStore].version = UCARMonitorStoreVersionNew;
[UCARMonitorNewStore sharedStore].appVersion = @"700100";
UCARMonitorNewStore sharedStore].userID = @"700100";
[UCARMonitorNewStore sharedStore].appName = UCARMonitorAppNameFCAR;
[UCARMonitorNewStore sharedStore].mobile = @"15669710443";
```

## 接入

### App生命周期事件

UCARMonitorStore.h 中有相应API，内有详细说明，接入即可。

### VC生命周期事件

UIViewController+UCARMonitor.h 中有相应API，内有详细说明，接入即可。

### Crash

Monitor初始化之后，调用 UCARMonitorStore+Crash.h 中的 beginMonitorCrash。
