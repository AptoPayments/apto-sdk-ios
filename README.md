# Shift SDK
Shift iOS SDK.

For more information, see the [website](https://developer.ledge.me).

## Requirements

* iOS version; 10.0+

## Developer Guides

### Installation

1. In your Podfile, add the following dependency:

```
pod ShiftSDK
```

#### Distributing your app via Testflight or App Store

The Shift SDK includes the [Plaid iOS SDK](https://github.com/plaid/link/tree/master/ios) as a dependency in order to
handle the communication with bank entities. Plaid SDK requires to run a
[shell script](https://github.com/plaid/link/blob/master/ios/LinkKit.framework/prepare_for_distribution.sh) that removes
any non-iOS device code from the framework which is included to support running their framework in the iOS Simulator but
may not be distributed via the App Store.

To run execute this script you have to add a New Run Script Phase in the Build Phases of your project with the following
content:

```bash
LINK_ROOT=${PODS_ROOT:+$PODS_ROOT/Plaid/ios}
cp "${LINK_ROOT:-$PROJECT_DIR}"/LinkKit.framework/prepare_for_distribution.sh "${CODESIGNING_FOLDER_PATH "/Frameworks/LinkKit.framework/prepare_for_distribution.sh
"${CODESIGNING_FOLDER_PATH}"/Frameworks/LinkKit.framework/prepare_for_distribution.sh
```

More details in the <a href="https://plaid.com/docs/link/ios/#add-run-script" target="_blank">Plaid SDK documentation</a>

### Example app

There is an example app which make use of the SDK. You can install the example app to check out the Link flow.

1. In the `Example/Demo/ViewControllers/MainViewController.swift`, edit the organization and project keys (from Sandbox):
  * Define the `<Organization Key>`.
  * Define the `<Project Key>`.
1. Select Scheme `ShiftSDK Demo Sandbox`
1. Build and Run (CMD+R)

### Using the SDKs

To run the SDK first you need to set it up with your keys and the current context:
```swift
ShiftPlatform.defaultManager().initializeWithDeveloperKey("<Organization Key>",
                                                           projectKey: "<Project Key>")
```
This is required for both the Link SDK and the Card SDK.
Optionally, you can configure if you want to enable certificate pinning, if you want to trust self-signed certificates, and which environment you want to target ("sanbox" or "production")

```swift
ShiftPlatform.defaultManager().initializeWithDeveloperKey("<Organization Key>",
                                                          projectKey: "<Project Key>",
                                                          environment: .sandbox,
                                                          setupCertPinning: true)
```

After you have done the setup, you can launch the desired SDK passing in the context.

For the Link flow use:
```swift
let shiftSession = ShiftSession()
shiftSession.startLinkFlow(from: self)
```
For the Shift card flow use:
```swift
let shiftSession = ShiftSession()
shiftSession.startCardFlow(from: self)
```

Additionally, you can initialize the SDK with the datapoints you already have:

```swift
let userDataPoints = DataPointList()
(... add datapoints to the datapoint list)

let shiftSession = ShiftSession()
shiftSession.startLinkFlow(from: self initialUserData: userDataPoints)
```

```swift
let userDataPoints = DataPointList()
(... add datapoints to the datapoint list)

let shiftSession = ShiftSession()
shiftSession.startCardFlow(from: self initialUserData: userDataPoints)
```

In all previous cases you **must retain** the `shiftSession` object.

#### Platform delegate

You can set a delegate to the `ShiftPlatform` class to be notified some events.

```swift
ShiftPlatform.defaultManager().delegate = delegateObject
```

The `delegate` methods are called in response to important events happening in the SDK:

1. Once the SDK is completely initialized and ready to be use (see section **Using the SDKs**) the method
`shiftSDKInitialized(developerKey:, projectKey:)` is called.
2. Every time the user authentication status change (sign up, sign in or logout) the method `newUserTokenReceived(_:)`
is called with the user authentication token or `nil` for logout.

The other two methods in the `ShiftPlatformDelegate` are **optional** and related to handling network reachability
issues. Those methods are optional because the SDK already implement a way to handle reachability issues (a UI blocking
view with a message is presented and automatically dismissed when the connection is restored). You can still receive
the notification and kept the responsibility of handling the issues to the SDK by returning `false` from the
implementation of the method `networkConnectionError()`.

**Note:** Once the connection is restored all failed requests will be automatically sent independently if the issue is
handled by you or by the SDK.

3. When a network request fails due to reachability issues we call the function `networkConnectionError() -> Bool`. As
previously mentioned you can decide if you want to handle the issue or if you transfer the responsibility to the
Shift SDK.
4. Once the Internet connection is restored we call the method `networkConnectionRestored()`. The behaviour of the SDK
in this case will depends on the value returned from the previous call to `networkConnectionError()`.

### Github pages

The Github pages website is stored in the `dev-gh-pages` branch.

# License

All rights reserved Shift Financial, Inc (C) 2018. See the [LICENSE](LICENSE.md) file for more info.
