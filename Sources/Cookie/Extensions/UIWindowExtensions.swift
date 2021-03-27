//
//  UIWindowExtensions.swift
//
//
//  Created by Rafael Leão on 18.09.21.
//

import UIKit

extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if let event = event,
           event.type == .motion,
           event.subtype == .motionShake {
            Cookie.shared.handleShake()
        }
        super.motionEnded(motion, with: event)
    }

    static var key: UIWindow? {
        return UIApplication.shared.windows.first { $0.isKeyWindow }
    }
}
