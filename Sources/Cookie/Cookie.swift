import Foundation
import SwiftUI

@available(iOS 16.0, *)
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
    private var requestInterceptor: RequestInterceptor = ProtocolClassesInterceptor.shared

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

@available(iOS 16.0, *)
@available(macOS 13, *)
extension Cookie: RequestInterceptorDelegate {
    func shouldFireRequest(urlRequest: URLRequest) -> Bool {
        true
    }

    func willFireRequest(urlRequest: URLRequest, hash: Int) {
        Task {
            await requestRepository.addRequest(urlRequest: urlRequest, hash: hash)
        }
    }

    func didComplete(request: URLRequest, response: HTTPResponse, hash: Int) {
        Task {
            await requestRepository.setResponse(urlRequest: request, response: response, hash: hash)
        }
    }

    func webSocketDidSendMessage(task: URLSessionTask, message: URLSessionWebSocketTask.Message) {
        Task {
            await requestRepository.messageSent(task: task, message: message)
        }
    }

    func webSocketDidReceive(task: URLSessionTask, message: URLSessionWebSocketTask.Message) {
        Task {
            await requestRepository.messageReceived(task: task, message: message)
        }
    }
}
