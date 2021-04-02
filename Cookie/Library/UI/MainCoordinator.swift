//
//  MainCoordinator.swift
//  Cookie
//
//  Created by Rafael Leao on 02.04.21.
//

import Foundation
import SwiftUI

class MainCoordinator {

    static let shared = MainCoordinator()

    func start() {
        let view = RequestList(viewModel: RequestListViewModel())
        let viewController = UIHostingController(rootView: view)
        topViewController()?.present(viewController, animated: true, completion: nil)
    }

    private func topViewController() -> UIViewController? {
        var topViewController = UIWindow.key?.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}

extension UIWindow {
    static var key: UIWindow? {
        return UIApplication.shared.windows.first { $0.isKeyWindow }
    }
}
