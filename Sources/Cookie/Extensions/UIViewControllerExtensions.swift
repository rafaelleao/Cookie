//
//  UIViewControllerExtensions.swift
//
//
//  Created by Rafael Leão on 18.09.21.
//

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

#elseif os(macOS)

import AppKit

extension NSWindow {
//    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//        if let event = event,
//           event.type == .motion,
//           event.subtype == .motionShake {
//            Cookie.shared.handleShake()
//        }
//        super.motionEnded(motion, with: event)
//    }

    static var key: NSWindow? {
        NSApplication.shared.windows.first { $0.isKeyWindow }
    }
}

extension NSViewController {
    static var top: NSViewController? {
        var topViewController = NSWindow.key?.contentViewController
//        while let presentedViewController = topViewController?.presentedViewController {
//            topViewController = presentedViewController
//        }
        return topViewController
    }
}

#endif
