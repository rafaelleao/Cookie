import Foundation
import Core

public protocol RequestDelegate: AnyObject {

    func shouldFireURLRequest(_ urlRequest: URLRequest) -> Bool
    func willFireRequest(_ httpRequest: HTTPRequest)
    func didCompleteRequest(_ httpRequest: HTTPRequest)
}
