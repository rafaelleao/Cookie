import Foundation
import Networking
import SwiftUI

@available(iOS 16.0, *)
@available(macOS 13, *)
@MainActor
public class Cookie {
    public enum SwizzlingMethod: String {
        case protocolClasses
        case NSURLSwizzling
    }

    public var swizzlingMethod: SwizzlingMethod = .NSURLSwizzling

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
    private lazy var requestInterceptor: RequestInterceptor = {
        if swizzlingMethod == .protocolClasses {
            return ProtocolClassesInterceptor.shared
        }
        return SwizzlingRequestInterceptor()
    }()

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
        try? requestInterceptor.activate()
        enabled = true
    }

    private func disable() {
        requestInterceptor.delegate = nil
        try? requestInterceptor.deactivate()
        enabled = false
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

@available(iOS 16.0, *)
@available(macOS 13, *)
extension Cookie: RequestInterceptorDelegate {
    public func shouldFireRequest(urlRequest: URLRequest) -> Bool {
        true
    }

    public func willFireRequest(urlRequest: URLRequest, hash: Int) {
        Task {
            await requestRepository.addRequest(urlRequest: urlRequest, hash: hash)
        }
    }

    public func didComplete(request: URLRequest, response: HTTPResponse, hash: Int) {
        Task {
            await requestRepository.setResponse(urlRequest: request, response: response, hash: hash)
        }
    }

    public func webSocketDidSendMessage(task: URLSessionTask, message: URLSessionWebSocketTask.Message) {
        Task {
            await requestRepository.messageSent(task: task, message: message)
        }
    }

    public func webSocketDidReceive(task: URLSessionTask, message: URLSessionWebSocketTask.Message) {
        Task {
            await requestRepository.messageReceived(task: task, message: message)
        }
    }
}
