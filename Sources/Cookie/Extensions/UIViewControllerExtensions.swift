//
//  UIViewControllerExtensions.swift
//
//
//  Created by Rafael Leão on 18.09.21.
//

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
