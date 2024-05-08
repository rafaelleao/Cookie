import Foundation

@available(macOS 10.15, *)
protocol RequestInterceptorDelegate: AnyObject {
    func shouldFireRequest(urlRequest: URLRequest) -> Bool
    func willFireRequest(urlRequest: URLRequest, hash: Int)
    func didComplete(request: URLRequest, response: HTTPResponse, hash: Int)
}

protocol RequestInterceptor {
    var delegate: RequestInterceptorDelegate? { get set }
    func activate()
    func deactivate()
}
