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

    let requestRepository = RequestRepository()
    private let coordinator = MainCoordinator()

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
        RequestInterceptor.shared.delegate = self
        RequestInterceptor.shared.activate()
    }

    private func disable() {
        RequestInterceptor.shared.delegate = nil
        RequestInterceptor.shared.deactivate()
    }

    func handleShake() {
        if settings.shakeGestureEnabled {
            present()
        }
    }
}

@available(macOS 13.0, *)
protocol RequestRepositoryDelegate: AnyObject {
    func requestRepository(_ requestRepository: RequestRepository, didAddRequest httpRequest: HTTPRequest)
}

@available(macOS 13.0, *)
actor RequestRepository {
    private(set) var requests = [HTTPRequest]()
    private var openRequests = [Int: HTTPRequest]()
    private weak var delegate: RequestRepositoryDelegate?

    func clearRequests() {
        requests.removeAll()
    }

    func setDelegate(_ delegate: RequestRepositoryDelegate) {
        self.delegate = delegate
    }

    func addRequest(urlRequest: URLRequest, hash: Int) {
        let request = HTTPRequest(request: urlRequest)
        requests.insert(request, at: 0)
        assert(openRequests[hash] == nil)
        openRequests[hash] = request
        delegate?.requestRepository(self, didAddRequest: request)
    }

    func setResponse(urlRequest: URLRequest, response: HTTPResponse?, hash: Int) {
        guard let httpRequest = openRequests[hash] else {
            return
        }
        httpRequest.responseDate = Date()
        httpRequest.response = response
        openRequests[hash] = nil
    }
}

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
}

public class Settings {
    public var fullscreen = true
    public var shakeGestureEnabled = true
}
