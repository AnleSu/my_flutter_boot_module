# 导入人脸识别Framework

### Step 1

  ```
  pod 'UCARFaceID'
  ```

###  Step 2

  在`info.plist`检查是否存在以下内容，没有请添加

* 因为人脸识别需要调用相机，所以请将司机端项目的`info.plist`中加入`Privacy - Camera Usage Description`，值为`App需要访问您的相机`（具体文案以产品为主）

* 因为人脸识别接口为http，所以请将司机端项目的`info.plist`中加入`App Transport Security Settings`，值为如下

  ```
  <key>NSAppTransportSecurity</key>
  <dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
  </dict>
  ```

###  Step 3

  在司机端`AppDelegate.m`添加以下代码，启动人脸识别服务

  ```objective-c
  #import "AppDelegate.h"
  #import <UCARFaceID/UCarLive.h>

  @interface AppDelegate ()

  @end

  @implementation AppDelegate

  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  	// Override point for customization after application launch.
  	[UCARFaceIDService startService];
  	return YES;
  }

  ```

###   Step 4

  > 将调用`<UCarLive/UCarLive.h>`的实现类（`.m`）文件，后缀改为`.mm`

###  Step 5
  
  ```
  #import <UCARFaceID/UCarLive.h>
  ```
  
  具体调用方法见`Demo`中的`ViewController.mm`



