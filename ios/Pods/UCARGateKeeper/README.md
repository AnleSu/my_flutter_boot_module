使用说明
========

安装
----

``` {.sourceCode .ruby}
pod 'UCARGateKeeper'
```

初始化
------

### 前置依赖

初始化之前必须先初始化环境变量，即初始化 **UCAREnvConfig** 。

注： **UCAREnvConfig** 位于 UCARUtility 库中。

### 必要参数

1.  configFileName

配置文件名，不包含后缀，直接从mainBundle中读取

注：必须为plist文件

2.  appVersion

App版本号

3.  cid

API版本号，一般为 业务线编码 + 版本，如"700100"。

### 示例

``` {.sourceCode .objc}
[UCAREnvConfig initWithConfigFileName:@"config" envKey:UCAREnvDev1];
[UCARGateKeeperManager initServiceWithConfig:@"gatekeeperconfig" appVersion:@"700350" cid:@"700350"];
```

后台配置
--------

链接 <http://gatekeepertest.10101111.com>

不同环境域名不同

账号 admin/gk\_admin

生产环境账号需要申请
