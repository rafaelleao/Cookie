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

    func present(_ fullscreen: Bool) {
        if presentingViewController != nil {
            dismiss()
            return
        }
        let view = RequestList(viewModel: RequestListViewModel())
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
