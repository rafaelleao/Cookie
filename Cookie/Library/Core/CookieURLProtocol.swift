import Foundation

class CookieURLProtocol: URLProtocol {

    private var sessionTask: URLSessionTask?
    private lazy var internalResponseData = Data()
    private lazy var session: URLSession = {
        let configuration = RequestInterceptor.shared.configuration
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    private class func shouldIntercept(request: URLRequest) -> Bool {
        guard let scheme = request.url?.scheme,
             ["http", "https"].contains(scheme) else {
            return false
        }

        return RequestInterceptor.shared.shouldInterceptRequest(request)
    }

    override class func canInit(with task: URLSessionTask) -> Bool {

        guard let request = task.currentRequest ?? task.originalRequest else {
            return false
        }
        return shouldIntercept(request: request)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return shouldIntercept(request: request)
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        sessionTask = session.dataTask(with: request)
        RequestInterceptor.shared.willFireRequest(request, hash: hash)
        sessionTask?.resume()
    }

    override public func stopLoading() {
        sessionTask?.cancel()
        sessionTask = nil
    }
}

extension CookieURLProtocol: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            RequestInterceptor.shared.didComplete(request: request, response: task.response as? HTTPURLResponse, error: error, hash: hash)
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            guard let response = task.response as? HTTPURLResponse else {
                fatalError()
            }
            print(request, sessionTask, self.hash)
            RequestInterceptor.shared.didReceiveResponse(urlRequest: request, response: response, data: internalResponseData, hash: hash)
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        internalResponseData.append(data)
        client?.urlProtocol(self, didLoad: data)
    }
}
