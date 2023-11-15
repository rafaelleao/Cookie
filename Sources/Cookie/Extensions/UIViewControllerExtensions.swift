#if os(iOS)

import UIKit

extension UIViewController {
    static var top: UIViewController? {
        var topViewController = UIWindow.key?.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}

#endif
