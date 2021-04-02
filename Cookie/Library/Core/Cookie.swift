import Foundation

public class Cookie {

    public static let shared = Cookie()
    public weak var delegate: RequestDelegate?

    private let queue = DispatchQueue(label: "Cookie")
    var requests = [HTTPRequest]()
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

    private func requestFor(urlRequest: URLRequest) -> HTTPRequest? {
        return requests.first(where: { httpRequest -> Bool in
            httpRequest.urlRequest == urlRequest && httpRequest.response == nil
        })
    }
}

extension Cookie: RequestInterceptorDelegate {

    func shouldFireRequest(urlRequest: URLRequest) -> Bool {
        return delegate?.shouldFireURLRequest(urlRequest) ?? true
    }

    func willFireRequest(urlRequest: URLRequest) {
        queue.sync {
            let request = HTTPRequest(request: urlRequest)
            requests.insert(request, at: 0)
            internalDelegate?.willFireRequest(request)
            delegate?.willFireRequest(request)
        }
    }

    public func didReceiveResponse(urlRequest: URLRequest, response: HTTPURLResponse, data: Data?) {
        queue.sync {
            if let httpRequest = requestFor(urlRequest: urlRequest) {
                httpRequest.responseDate = Date()
                httpRequest.response = HTTPResponse.success(response: response, data: data)
                internalDelegate?.didCompleteRequest(httpRequest)
                delegate?.didCompleteRequest(httpRequest)
            }
        }
    }

    public func didComplete(request urlRequest: URLRequest, response: HTTPURLResponse?, error: Error?) {
        queue.sync {
            if let httpRequest = requestFor(urlRequest: urlRequest) {
                httpRequest.response = HTTPResponse.failure(response: response, error: error)
                httpRequest.responseDate = Date()
                internalDelegate?.didCompleteRequest(httpRequest)
                delegate?.didCompleteRequest(httpRequest)
            }
        }
    }
}
