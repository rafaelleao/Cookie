import Foundation

@available(macOS 10.15, *)
class CookieURLProtocol: URLProtocol {
    private var sessionTask: URLSessionTask?
    private lazy var internalResponseData = Data()
    private static var requestInterceptor = RequestInterceptor.shared
    private lazy var session: URLSession = URLSession(configuration: Self.requestInterceptor.configuration, delegate: self, delegateQueue: nil)

    private class func shouldIntercept(request: URLRequest) -> Bool {
        guard let scheme = request.url?.scheme, ["http", "https"].contains(scheme)
        else {
            return false
        }

        return requestInterceptor.shouldInterceptRequest(request)
    }

    override class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest ?? task.originalRequest else {
            return false
        }
        return shouldIntercept(request: request)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        shouldIntercept(request: request)
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        sessionTask = session.dataTask(with: request)
        Self.requestInterceptor.willFireRequest(request, hash: hash)
        sessionTask?.resume()
    }

    override func stopLoading() {
        sessionTask?.cancel()
        sessionTask = nil
    }
}

@available(macOS 10.15, *)
extension CookieURLProtocol: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            Self.requestInterceptor.didComplete(
                request: request,
                response: task.response as? HTTPURLResponse,
                error: error,
                hash: hash
            )
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            guard let response = task.response as? HTTPURLResponse else {
                client?.urlProtocol(self, didFailWithError: NSError(domain: "CookieURLProtocol", code: -1))
                Self.requestInterceptor.didComplete(
                    request: request,
                    response: nil,
                    error: nil,
                    hash: hash
                )
                return
            }
            Self.requestInterceptor.didReceiveResponse(
                urlRequest: request,
                response: response,
                data: internalResponseData,
                hash: hash
            )
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        internalResponseData.append(data)
        client?.urlProtocol(self, didLoad: data)
    }
}
