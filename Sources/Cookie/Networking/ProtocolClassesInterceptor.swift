import Foundation

@available(macOS 10.15, *)
class ProtocolClassesInterceptor: RequestInterceptor {
    static let shared = ProtocolClassesInterceptor()
    let configuration: URLSessionConfiguration
    weak var delegate: RequestInterceptorDelegate?
    static let protocolKey = "URLProtocol"
    static let protocolValue = "CookieURLProtocol"
    static let protocolClass = CookieURLProtocol.self

    init() {
        self.configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [ProtocolClassesInterceptor.protocolKey: ProtocolClassesInterceptor.protocolValue]
    }

    func activate() {
        URLProtocol.registerClass(Self.protocolClass)
        swizzleProtocolClasses()
    }

    func deactivate() {
        URLProtocol.unregisterClass(Self.protocolClass)
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

    func webSocketDidSendMessage(task: URLSessionTask, message: URLSessionWebSocketTask.Message) {
        delegate?.webSocketDidSendMessage(task: task, message: message)
    }

    func webSocketDidReceive(task: URLSessionTask, message: URLSessionWebSocketTask.Message) {
        delegate?.webSocketDidReceive(task: task, message: message)
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
