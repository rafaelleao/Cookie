import Foundation

@available(macOS 10.15, *)
public protocol RequestInterceptorDelegate: AnyObject {
    func shouldFireRequest(urlRequest: URLRequest) -> Bool
    func willFireRequest(urlRequest: URLRequest, hash: Int)
    func didComplete(request: URLRequest, response: HTTPResponse, hash: Int)

    func webSocketDidSendMessage(task: URLSessionTask, message: URLSessionWebSocketTask.Message)
    func webSocketDidReceive(task: URLSessionTask, message: URLSessionWebSocketTask.Message)
}

@available(macOS 10.15, *)
enum SwizzlingError: Error {
    case classNotFound
    case methodNotFound
    case instancesDoesNotRespondToSelector
}

@available(macOS 10.15, *)
public protocol RequestInterceptor {
    var delegate: RequestInterceptorDelegate? { get set }
    func activate() throws
    func deactivate() throws
}
