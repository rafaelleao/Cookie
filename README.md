# Cookie

A lightweight network traffic debugging tool for iOS apps.

Written in SwiftUI, supports iOS 13+

## Features

<p float="left">
  <img src="https://github.com/rafaelleao/Cookie/blob/screenshots/screenshots/img1.png" width="250" />
  <img src="https://github.com/rafaelleao/Cookie/blob/screenshots/screenshots/img2.png" width="250" />
  <img src="https://github.com/rafaelleao/Cookie/blob/screenshots/screenshots/img3.png" width="250" />
</p>

- List all HTTP and HTTPS traffic from URLSessions run with configuration URLSessionConfiguration.default
- Search requests by url
- Display detailed information about each request, including text search
- Inspect request/response body and headers

## Installation
### Swift Package Manager

```
https://github.com/rafaelleao/Cookie.git
```

## Setup
First, enable Cookie before any request is fired (e.g. in `application(:, didFinishLaunchingWithOptions:)` ) by calling `Cookie.shared.enabled = true`

```swift
import Cookie

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Cookie.shared.enabled = true

        return true
    }
}
```

Then, from any point in the application you can visualize the requests calling:
```swift
Cookie.shared.present()
```

The tool can also be displayed with a shake gesture.
