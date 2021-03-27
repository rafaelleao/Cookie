import Foundation

public class Cookie {
    public static let shared = Cookie()
    public weak var delegate: RequestDelegate?
    public var settings = Settings()
    public var enabled = false {
        didSet {
            if oldValue != enabled {
                enabled ? enable() : disable()
            }
        }
    }

    public private(set) var requests = [HTTPRequest]()

    private let queue = DispatchQueue(label: "Cookie")
    private var openRequests = [Int: HTTPRequest]()
    private let coordinator = MainCoordinator()
    weak var internalDelegate: RequestDelegate?

    public func clearRequests() {
        requests.removeAll()
    }

    public func present() {
        coordinator.present(settings.fullscreen)
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

    internal func handleShake() {
        if settings.shakeGestureEnabled {
            present()
        }
    }

    private func requestFor(urlRequest: URLRequest, hash: Int) -> HTTPRequest? {
        openRequests[hash]
    }
}

extension Cookie: RequestInterceptorDelegate {
    func shouldFireRequest(urlRequest: URLRequest) -> Bool {
        return delegate?.shouldFireURLRequest(urlRequest) ?? true
    }

    func willFireRequest(urlRequest: URLRequest, hash: Int) {
        queue.sync {
            let request = HTTPRequest(request: urlRequest)
            requests.insert(request, at: 0)
            assert(openRequests[hash] == nil)
            openRequests[hash] = request
            internalDelegate?.willFireRequest(request)
            delegate?.willFireRequest(request)
        }
    }

    func didReceiveResponse(urlRequest: URLRequest, response: HTTPURLResponse, data: Data?, hash: Int) {
        queue.sync {
            if let httpRequest = requestFor(urlRequest: urlRequest, hash: hash) {
                httpRequest.responseDate = Date()
                httpRequest.response = HTTPResponse.success(response: response, data: data)
                internalDelegate?.didCompleteRequest(httpRequest)
                delegate?.didCompleteRequest(httpRequest)
                openRequests[hash] = nil
            }
        }
    }

    func didComplete(request urlRequest: URLRequest, response: HTTPURLResponse?, error: Error?, hash: Int) {
        queue.sync {
            if let httpRequest = requestFor(urlRequest: urlRequest, hash: hash) {
                httpRequest.response = HTTPResponse.failure(response: response, error: error)
                httpRequest.responseDate = Date()
                internalDelegate?.didCompleteRequest(httpRequest)
                delegate?.didCompleteRequest(httpRequest)
                openRequests[hash] = nil
            }
        }
    }
}

public class Settings {
    public var fullscreen = true
    public var shakeGestureEnabled = true
}
