# UCARDeviceToken

[![CI Status](https://img.shields.io/travis/闫子阳/UCARDeviceToken.svg?style=flat)](https://travis-ci.org/闫子阳/UCARDeviceToken)
[![Version](https://img.shields.io/cocoapods/v/UCARDeviceToken.svg?style=flat)](https://cocoapods.org/pods/UCARDeviceToken)
[![License](https://img.shields.io/cocoapods/l/UCARDeviceToken.svg?style=flat)](https://cocoapods.org/pods/UCARDeviceToken)
[![Platform](https://img.shields.io/cocoapods/p/UCARDeviceToken.svg?style=flat)](https://cocoapods.org/pods/UCARDeviceToken)

使用钥匙串数据进行持久化存储，目的使app的设备号保持唯一，并可进行不同app，不同设备之间的数据同步。

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Project Config

1. 开启Keychain Sharing : target->Capabilities->Keychain Sharing。如果不进行数据共享，并且不主动设置access group，可不开启。数据会默认存在bundle项中。

2. 如果开启Keychain Sharing后，可设置Keychain Groups：可任意设置，一般默认为当前工程的bundle id（与不开启数据存储位置相同），如果想多个app共享数据，需要有相同的team id，设置相同的access group。

3. 系统会将teamId以及Keychain Groups值拼接起来放在 **工程名.entitlements** 证书中，如果没有设置access group，会默认取证书中的第一个值作为access group。有获取team Id的方法，如果需要自定义设置access group，可将team id与自定义值拼接后传给UCARKeyChainConfig。

4. 钥匙串**存取数据时**默认会取**工程名.entitlements**中的第一项作为access group，所谓的第一项，是指第一次存取数据时的第一项，即使后续修改了顺序，再次读取此数据时，钥匙串依然会使用第一次存取此数据事的access group去取值，与当前顺序无关。但如果**工程名.entitlements**中无此access group，则无法取到该值。
5. 关于bundle项，如果之前已经存在的值没有主动设置access group，并且keychain sharing中默认为bundle id，或者设置的access group为bundle Id，即access group的值为**teamId.bundleId**，则此值会一直存在bundle项中，即使将keychain sharing中的项删除或者任意修改，此值依然会存在，能正常存取。
6. 对于符合第5点条件的值，如果存储的值不相同，则无法进行数据共享，如果需要进行数据共享，要重新设置新值，并且重新设置key值或者主动设置access group的值为同一个，否则即使**工程名.entitlements**证书中的第一项相同，取值时依然会从各自的bungle项中取，无法进行数据同步和共享。

7. 使用 **deviceUUID** 方法进行默认取值时，group 为默认值（不受步骤2中设置的影响）。
8. 使用**sharedDeviceUUID**方法获取共享的设备号，group和key值内部设置，需要保证同一个team Id，否则无法进行数据共享。

## Installation

UCARDeviceToken is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'UCARDeviceToken'
```

## Usage

just fetch the uuid

```objc

    NSString *deviceID = [UCARDeviceToken deviceUUID];

```

just fetch the shared uuid

```objc

NSString *deviceID = [UCARDeviceToken sharedDeviceUUID];

```

fetch team id

```objc

NSString *teamId = [UCARKeyChainManager getTeamId];

```

## Author

闫子阳, ziyang.yan@ucarinc.com

## License

UCARDeviceToken is available under the MIT license. See the LICENSE file for more info.
## Class Diagram
![](Image/class_diagram.png)
