import Combine
import Foundation

@available(macOS 10.15, *)
class HTTPRequest {
    let urlRequest: URLRequest
    let requestDate: Date
    @Published var response: HTTPResponse?
    var responseDate: Date?
    var requestBodyData: Data? {
        if let httpBody = urlRequest.httpBody {
            return httpBody
        }
        if let httpBodyStream = urlRequest.httpBodyStream {
            return Data(reading: httpBodyStream)
        }
        return nil
    }

    var requestBodyString: String? {
        guard let bodyData = requestBodyData else {
            return nil
        }

        if let jsonString = bodyData.toJsonString() {
            return jsonString
        }

        return bodyData.toString()
    }

    var contentType: String? {
        guard let headers = response?.urlResponse?.allHeaderFields,
              let contentType = headers["Content-Type"] as? String,
              let type = contentType.components(separatedBy: ";").first, !type.isEmpty
        else {
            return nil
        }

        return type
    }

    var domain: String? {
        urlComponents?.host
    }

    var urlComponents: NSURLComponents? {
        if let url = urlRequest.url {
            return NSURLComponents(url: url, resolvingAgainstBaseURL: true)
        } else {
            return nil
        }
    }

    init(request: URLRequest, date: Date = Date()) {
        self.urlRequest = request
        self.requestDate = date
    }
}

@available(macOS 13.0, *)
extension HTTPRequest: Equatable {
    static func == (lhs: HTTPRequest, rhs: HTTPRequest) -> Bool {
        lhs.urlRequest == rhs.urlRequest && lhs.requestDate == rhs.requestDate
    }
}
