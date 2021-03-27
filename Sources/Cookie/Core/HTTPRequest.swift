import Combine
import Foundation

public class HTTPRequest {
    public let urlRequest: URLRequest
    public let requestDate: Date
    @Published public var response: HTTPResponse?
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

    public var contentType: String? {
        guard let headers = response?.urlResponse?.allHeaderFields,
              let contentType = headers["Content-Type"] as? String,
              let type = contentType.components(separatedBy: ";").first, !type.isEmpty
        else {
            return nil
        }

        return type
    }

    init(request: URLRequest, date: Date = Date()) {
        self.urlRequest = request
        self.requestDate = date
    }
}

extension HTTPRequest: Equatable {
    public static func == (lhs: HTTPRequest, rhs: HTTPRequest) -> Bool {
        return lhs.urlRequest == rhs.urlRequest && lhs.requestDate == rhs.requestDate
    }
}
