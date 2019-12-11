# UCAROCRManager

[![CI Status](https://img.shields.io/travis/林锴/UCAROCRManager.svg?style=flat)](https://travis-ci.org/林锴/UCAROCRManager)
[![Version](https://img.shields.io/cocoapods/v/UCAROCRManager.svg?style=flat)](https://cocoapods.org/pods/UCAROCRManager)
[![License](https://img.shields.io/cocoapods/l/UCAROCRManager.svg?style=flat)](https://cocoapods.org/pods/UCAROCRManager)
[![Platform](https://img.shields.io/cocoapods/p/UCAROCRManager.svg?style=flat)](https://cocoapods.org/pods/UCAROCRManager)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

UCAROCRManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'UCAROCRManager'
```

## Author

林锴, kai.lin@ucarinc.com

## 使用流程
- OCR自由组合 - (包括 车架扫描、车牌扫描、二维码)
那么调用 UISCanViewController，具体使用参照 Example或者头文件方法描述

- 各个组件分别调用
那么分别调用
UCARIDCardCameraViewController
UCARSmartOCRCameraViewController

## 注意事项

- 主工程所需的文件-包括验证证书和3个.lib文件
**PS:这几个文件一定要放在主工程底下，要不ocr验证不过**

![alt text](./imgs/所需依赖文件.jpg "工程设置的Capabilities的权限要开启")

- bitcode报错

如果在Podfile中引入UCAROCRManager 
```
pod 'UCAROCRManager'
```

然后编译报bitcode错误，那么解决方法如下：
在podfile最后添加，以下代码
```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
```

