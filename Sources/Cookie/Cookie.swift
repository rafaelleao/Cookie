import Foundation
import SwiftUI

@available(macOS 13, *)
@MainActor
public class Cookie {
    public static let shared = Cookie()
    public var settings = Settings()
    public var enabled = false {
        didSet {
            if oldValue != enabled {
                if enabled {
                    enable()
                } else {
                    disable()
                }
            }
        }
    }

    let requestRepository = RequestRepositoryImpl()
    private let coordinator = MainCoordinator()
    private let requestInterceptor = RequestInterceptor.shared

    public func clearRequests() async {
        await requestRepository.clearRequests()
    }

    public func present() {
        coordinator.present(settings.fullscreen, requestRepository: requestRepository)
    }

    public func dimiss() {
        coordinator.dismiss()
    }

    private func enable() {
        requestInterceptor.delegate = self
        requestInterceptor.activate()
    }

    private func disable() {
        requestInterceptor.delegate = nil
        requestInterceptor.deactivate()
    }

    func handleShake() {
        if settings.shakeGestureEnabled {
            present()
        }
    }
}

public class Settings {
    public var fullscreen = true
    public var shakeGestureEnabled = true
}
