import Foundation

class RequestInterceptor {

    static let shared = RequestInterceptor()
    let configuration: URLSessionConfiguration
    weak var delegate: RequestInterceptorDelegate?
    internal static let protocolKey = "URLProtocol"
    internal static let protocolValue = "CookieURLProtocol"

    init() {
        configuration = URLSessionConfiguration.default
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

    func willFireRequest(_ urlRequest: URLRequest) {
        delegate?.willFireRequest(urlRequest: urlRequest)
    }

    func didReceiveResponse(urlRequest: URLRequest, response: HTTPURLResponse, data: Data) {
        delegate?.didReceiveResponse(urlRequest: urlRequest, response: response, data: data)
    }

    func didComplete(request: URLRequest, response: HTTPURLResponse?, error: Error?) {
        delegate?.didComplete(request: request, response: response, error: error)
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
        guard let fakeProtocolClasses = self.fakeProtocolClasses() else {
            return []
        }

        if self.httpAdditionalHeaders?[RequestInterceptor.protocolKey] as? String == RequestInterceptor.protocolValue {
            return fakeProtocolClasses
        }

        var originalProtocolClasses = fakeProtocolClasses.filter {
            return $0 != CookieURLProtocol.self
        }
        originalProtocolClasses.insert(CookieURLProtocol.self, at: 0)
        return originalProtocolClasses
    }
}
