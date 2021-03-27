import Foundation
import Core

public class Cookie {

    public static let shared = Cookie()
    public weak var delegate: RequestDelegate?

    private let queue = DispatchQueue(label: "Cookie")
    var requests = [HTTPRequest]()
    var openRequests = [Int: HTTPRequest]()
    var enabled = false
    weak var internalDelegate: RequestDelegate?

    public func enable() {
        guard !enabled else { return }

        enabled = true
        RequestInterceptor.shared.delegate = self
        RequestInterceptor.shared.activate()
    }

    public func disable() {
        guard enabled else { return }

        enabled = false
        RequestInterceptor.shared.delegate = nil
        RequestInterceptor.shared.deactivate()
    }
    
    public func clearRequests() {
        requests.removeAll()
    }
    
    public func presentViewController() {
        MainCoordinator.shared.start()
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
