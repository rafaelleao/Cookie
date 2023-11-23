import Foundation

@available(macOS 10.15, *)
protocol RequestInterceptorDelegate: AnyObject {
    func shouldFireRequest(urlRequest: URLRequest) -> Bool
    func willFireRequest(urlRequest: URLRequest, hash: Int)
    func didComplete(request: URLRequest, response: HTTPResponse, hash: Int)
}

@available(macOS 10.15, *)
class RequestInterceptor {
    static let shared = RequestInterceptor()
    let configuration: URLSessionConfiguration
    weak var delegate: RequestInterceptorDelegate?
    static let protocolKey = "URLProtocol"
    static let protocolValue = "CookieURLProtocol"

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
        delegate?.shouldFireRequest(urlRequest: urlRequest) ?? false
    }

    func willFireRequest(_ urlRequest: URLRequest, hash: Int) {
        delegate?.willFireRequest(urlRequest: urlRequest, hash: hash)
    }

    func didReceiveResponse(urlRequest: URLRequest, response: HTTPURLResponse, data: Data, hash: Int) {
        delegate?.didComplete(request: urlRequest, response: .success(response: response, data: data), hash: hash)
    }

    func didComplete(request: URLRequest, response: HTTPURLResponse?, error: Error?, hash: Int) {
        delegate?.didComplete(request: request, response: .failure(response: response, error: error), hash: hash)
    }

    // swiftlint:disable force_unwrapping
    private func swizzleProtocolClasses() {
        let instance = URLSessionConfiguration.default
        let uRLSessionConfigurationClass: AnyClass = object_getClass(instance)!

        let method1: Method = class_getInstanceMethod(
            uRLSessionConfigurationClass,
            #selector(getter: uRLSessionConfigurationClass.protocolClasses)
        )!
        let method2: Method = class_getInstanceMethod(
            URLSessionConfiguration.self,
            #selector(URLSessionConfiguration.fakeProtocolClasses)
        )!

        method_exchangeImplementations(method1, method2)
    }
    // swiftlint:enable force_unwrapping
}

@available(macOS 10.15, *)
extension URLSessionConfiguration {
    @objc func fakeProtocolClasses() -> [AnyClass]? {
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
