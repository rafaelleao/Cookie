import Foundation
import SwiftUI

#if os(iOS)

class MainCoordinator {
    private weak var presentingViewController: UIViewController?

    @MainActor
    func present(_ fullscreen: Bool, requestRepository: RequestRepositoryImpl) {
        if presentingViewController != nil {
            dismiss()
            return
        }
        let view = RequestList(viewModel: RequestListViewModelImpl(requestRepository: requestRepository))
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
class MainCoordinator: NSObject {
    private weak var window: NSWindow?

    @MainActor
    func present(_ fullscreen: Bool, requestRepository: RequestRepositoryImpl) {
        guard window == nil else { return }
        let view = RequestList(viewModel: RequestListViewModelImpl(requestRepository: requestRepository))
        let hostingController = NSHostingController(rootView: view)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = hostingController
        window.setFrameAutosaveName("Cookie Window")
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.delegate = self
        self.window = window
    }

    func dismiss() {
        window?.close()
    }
}

@available(macOS 13, *)
extension MainCoordinator: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        window = nil
    }
}

#endif
