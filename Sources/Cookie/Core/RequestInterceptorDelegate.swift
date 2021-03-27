import Foundation

protocol RequestInterceptorDelegate: AnyObject {
    func shouldFireRequest(urlRequest: URLRequest) -> Bool
    func willFireRequest(urlRequest: URLRequest, hash: Int)
    func didReceiveResponse(urlRequest: URLRequest, response: HTTPURLResponse, data: Data?, hash: Int)
    func didComplete(request: URLRequest, response: HTTPURLResponse?, error: Error?, hash: Int)
}
