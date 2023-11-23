#if os(iOS)

import UIKit

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if let event,
           event.type == .motion,
           event.subtype == .motionShake
        {
            if #available(iOS 16.0, *) {
                Cookie.shared.handleShake()
            }
        }
        super.motionEnded(motion, with: event)
    }

    static var key: UIWindow? {
        UIApplication.shared.windows.first { $0.isKeyWindow }
    }
}

#endif
