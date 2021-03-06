import Foundation

class RequestInterceptor {
    static let shared = RequestInterceptor()
    let configuration: URLSessionConfiguration
    weak var delegate: RequestInterceptorDelegate?
    internal static let protocolKey = "URLProtocol"
    internal static let protocolValue = "CookieURLProtocol"

    init() {
        self.configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [RequestInterceptor.protocolKey: RequestInterceptor.protocolValue]
    }

    func activate() {
        URLProtocol.registerClass(CookieURLProtocol.self)
        swizzleProtocolClasses()
    }

    func deactivate() {
        URLProtocol.unregisterClass(CookieURLProtocol.self)
        swizzleProtocolClasses()
    }

    func shouldInterceptRequest(_ urlRequest: URLRequest) -> Bool {
        return delegate?.shouldFireRequest(urlRequest: urlRequest) ?? false
    }

    func willFireRequest(_ urlRequest: URLRequest, hash: Int) {
        delegate?.willFireRequest(urlRequest: urlRequest, hash: hash)
    }

    func didReceiveResponse(urlRequest: URLRequest, response: HTTPURLResponse, data: Data, hash: Int) {
        delegate?.didReceiveResponse(urlRequest: urlRequest, response: response, data: data, hash: hash)
    }

    func didComplete(request: URLRequest, response: HTTPURLResponse?, error: Error?, hash: Int) {
        delegate?.didComplete(request: request, response: response, error: error, hash: hash)
    }

    private func swizzleProtocolClasses() {
        let instance = URLSessionConfiguration.default
        let uRLSessionConfigurationClass: AnyClass = object_getClass(instance)!

        let method1: Method = class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.protocolClasses))!
        let method2: Method = class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.fakeProtocolClasses))!

        method_exchangeImplementations(method1, method2)
    }
}

extension URLSessionConfiguration {
    @objc
    func fakeProtocolClasses() -> [AnyClass]? {
        guard let fakeProtocolClasses = fakeProtocolClasses() else {
            return []
        }

        if httpAdditionalHeaders?[RequestInterceptor.protocolKey] as? String == RequestInterceptor.protocolValue {
            return fakeProtocolClasses
        }

        var originalProtocolClasses = fakeProtocolClasses.filter {
            $0 != CookieURLProtocol.self
        }
        originalProtocolClasses.insert(CookieURLProtocol.self, at: 0)
        return originalProtocolClasses
    }
}
