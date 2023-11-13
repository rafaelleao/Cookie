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

    @MainActor
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
    private weak var window: NSWindow?

    @MainActor
    func present(_ fullscreen: Bool) {
        guard window == nil else { return }
        let view = RequestList(viewModel: RequestListViewModelImpl())
        let hostingController = NSHostingController(rootView: view)
        let window = NSPanel(
        contentRect: NSRect(x: 0, y: 0, width: 480, height: 600),
        styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        backing: .buffered, defer: false)
        window.contentViewController = hostingController
        window.setFrameAutosaveName("Cookie Window")
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.window = window
    }

    func dismiss() {
        window?.close()
    }
}

#endif
