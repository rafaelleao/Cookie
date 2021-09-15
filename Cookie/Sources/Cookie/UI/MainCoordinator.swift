//
//  MainCoordinator.swift
//  Cookie
//
//  Created by Rafael Leao on 02.04.21.
//

import Foundation
import SwiftUI

class MainCoordinator {

    private weak var presentingViewController: UIViewController?
    
    func present() {
        if presentingViewController != nil {
            dimiss()
            return
        }
        let view = RequestList(viewModel: RequestListViewModel())
        let viewController = UIHostingController(rootView: view)
        UIViewController.top?.present(viewController, animated: true, completion: nil)
        presentingViewController = viewController
    }
    
    func dimiss() {
        presentingViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.presentingViewController = nil
        })
    }
}

private extension UIViewController {
    static var top: UIViewController? {
        var topViewController = UIWindow.key?.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}

private extension UIWindow {
    static var key: UIWindow? {
        return UIApplication.shared.windows.first { $0.isKeyWindow }
    }
}
