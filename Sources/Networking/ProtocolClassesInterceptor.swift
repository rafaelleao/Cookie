import Foundation

@available(macOS 10.15, *)
public class ProtocolClassesInterceptor: RequestInterceptor {
    public static let shared = ProtocolClassesInterceptor()
    let configuration: URLSessionConfiguration
    public weak var delegate: RequestInterceptorDelegate?
    static let protocolKey = "URLProtocol"
    static let protocolValue = "CookieURLProtocol"
    static let protocolClass = CookieURLProtocol.self

    init() {
        self.configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [ProtocolClassesInterceptor.protocolKey: ProtocolClassesInterceptor.protocolValue]
    }

    public func activate() throws {
        URLProtocol.registerClass(Self.protocolClass)
        try swizzleProtocolClasses()
    }

    public func deactivate() throws {
        URLProtocol.unregisterClass(Self.protocolClass)
        try swizzleProtocolClasses()
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

    private func swizzleProtocolClasses() throws {
        let instance = URLSessionConfiguration.default
        guard let uRLSessionConfigurationClass = object_getClass(instance) else {
            throw SwizzlingError.classNotFound
        }

        guard let method1: Method = class_getInstanceMethod(
            uRLSessionConfigurationClass,
            #selector(getter: uRLSessionConfigurationClass.protocolClasses)
        ),
            let method2: Method = class_getInstanceMethod(
                URLSessionConfiguration.self,
                #selector(URLSessionConfiguration.fakeProtocolClasses)
            )
        else {
            throw SwizzlingError.methodNotFound
        }

        method_exchangeImplementations(method1, method2)
    }
}

@available(macOS 10.15, *)
extension URLSessionConfiguration {
    @objc func fakeProtocolClasses() -> [AnyClass]? {
        guard let fakeProtocolClasses = fakeProtocolClasses() else {
            return []
        }

        if httpAdditionalHeaders?[ProtocolClassesInterceptor.protocolKey] as? String == ProtocolClassesInterceptor.protocolValue {
            return fakeProtocolClasses
        }

        var originalProtocolClasses = fakeProtocolClasses.filter {
            $0 != ProtocolClassesInterceptor.protocolClass
        }
        originalProtocolClasses.insert(ProtocolClassesInterceptor.protocolClass, at: 0)
        return originalProtocolClasses
    }
}
