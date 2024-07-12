import Combine
import Foundation

@available(macOS 10.15, *)
public class HTTPRequest: Equatable {
    public enum WebsocketMessageType {
        case sent
        case received
    }

    public struct WebsocketMessage {
        public let date: Date
        public let message: URLSessionWebSocketTask.Message
        public let id = UUID()
        public let type: WebsocketMessageType

        public init(message: URLSessionWebSocketTask.Message, type: WebsocketMessageType) {
            self.date = .init()
            self.message = message
            self.type = type
        }
    }

    public let urlRequest: URLRequest
    public let requestDate: Date
    @Published public private(set) var response: HTTPResponse?
    public private(set) var responseDate: Date?
    public var requestBodyData: Data? {
        if let httpBody = urlRequest.httpBody {
            return httpBody
        }
        if let httpBodyStream = urlRequest.httpBodyStream {
            return Data(reading: httpBodyStream)
        }
        return nil
    }

    @Published public private(set) var webSockedMessages: [WebsocketMessage] = []

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

    public var domain: String? {
        urlComponents?.host
    }

    public var urlComponents: NSURLComponents? {
        if let url = urlRequest.url {
            return NSURLComponents(url: url, resolvingAgainstBaseURL: true)
        } else {
            return nil
        }
    }

    public init(request: URLRequest, date: Date = Date()) {
        self.urlRequest = request
        self.requestDate = date
    }

    public func setResponse(_ response: HTTPResponse) {
        self.response = response
        responseDate = Date()
    }

    public func apprendWebSockedMessage(_ message: WebsocketMessage) {
        webSockedMessages.append(message)
    }
}

@available(macOS 10.15, *)
public extension HTTPRequest { //Equatable
    static func == (lhs: HTTPRequest, rhs: HTTPRequest) -> Bool {
        lhs.urlRequest == rhs.urlRequest && lhs.requestDate == rhs.requestDate
    }
}
