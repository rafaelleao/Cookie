import Foundation

public class HTTPRequest {

    public let urlRequest: URLRequest
    public let requestDate: Date
    public var response: HTTPResponse?
    public var responseDate: Date?
    public var requestBodyData: Data? {
        if let httpBody = urlRequest.httpBody {
            return httpBody
        }
        if let httpBodyStream = urlRequest.httpBodyStream {
            return Data(reading: httpBodyStream)
        }
        return nil
    }

    public var requestBodyString: String? {
        
        guard let bodyData = requestBodyData else {
            return nil
        }
        
        if let jsonString = bodyData.toJsonString() {
            return jsonString
        }

        return bodyData.toString()
    }

    public var tag: String?

    init(request: URLRequest) {
        self.urlRequest = request
        self.requestDate = Date()
    }
}

extension HTTPRequest: Equatable {
    public static func == (lhs: HTTPRequest, rhs: HTTPRequest) -> Bool {
        return lhs.urlRequest == rhs.urlRequest && lhs.requestDate == rhs.requestDate
    }
}

extension HTTPRequest: CustomStringConvertible {
    public var description: String {
        return "<\(type(of: self)): requestDate: \(requestDate) URL: \(urlRequest.url!)>"
    }
}
