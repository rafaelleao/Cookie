//
//  MainCoordinator.swift
//  Cookie
//
//  Created by Rafael Leao on 02.04.21.
//

import Foundation
import SwiftUI

#if os(iOS)

class MainCoordinator {
    private weak var presentingViewController: UIViewController?

    func present(_ fullscreen: Bool) {
        if presentingViewController != nil {
            dismiss()
            return
        }
        let view = RequestList(viewModel: RequestListViewModelImpl())
        let viewController = UIHostingController(rootView: view)
        if fullscreen {
            viewController.modalPresentationStyle = .fullScreen
        }
        UIViewController.top?.present(viewController, animated: true, completion: nil)
        presentingViewController = viewController
    }

    func dismiss() {
        presentingViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.presentingViewController = nil
        })
    }
}

#elseif os(macOS)

@available(macOS 13, *)
class MainCoordinator {
    private weak var presentingViewController: NSViewController?

    func present(_ fullscreen: Bool) {
        if presentingViewController != nil {
            dismiss()
            return
        }
        let view = RequestList(viewModel: RequestListViewModelImpl())
        let viewController = NSHostingController(rootView: view)
//        if fullscreen {
//            viewController.modalPresentationStyle = .fullScreen
//        }
        NSViewController.top?.presentAsModalWindow(viewController)
        presentingViewController = viewController
    }

    func dismiss() {
        presentingViewController?.dismiss(true)
    }
}

#endif
