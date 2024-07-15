import Foundation
import Networking

// swiftlint:disable force_unwrapping
@available(macOS 13.0, *)
enum TestRequest {
    static var testRequest: HTTPRequest {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todosaiejfoisjefiajo?qwertyuiop=asdfghjkl&zxcvbnm=zxcvbnm")!
        let request = URLRequest(url: url)
        let httpOperation = HTTPRequest(request: request)
        return httpOperation
    }

    static var completedTestRequest: HTTPRequest {
        let url = URL(string: "www.test.com/path?foo=bar&c&a=b")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["header": "test"]
        let httpOperation = HTTPRequest(request: request)
        let response = ["a": "b"]
        let jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)

        let httpResponse = HTTPURLResponse(url: url, statusCode: 201, httpVersion: nil, headerFields: ["header": "value"])
        httpOperation.setResponse(HTTPResponse.success(response: httpResponse!, data: jsonData))
        return httpOperation
    }

    static var webSocket: HTTPRequest {
        let request = TestRequest.completedTestRequest
        let testJsonString = [
            "param3": 10,
            "param1": "a",
            "param2": true,
            "dict": [
                "param3": 10,
                "param1": "a",
                "param2": true,
            ],
        ].toJsonString()

        ([
            .init(message: .string(testJsonString), type: .sent),
            .init(message: .string("test"), type: .received),
            .init(message: .string(testJsonString), type: .sent),
        ] as [HTTPRequest.WebsocketMessage]).forEach {
            request.apprendWebSockedMessage($0)
        }
        return request
    }

    static var serverErrorRequest: HTTPRequest {
        let url = URL(string: "https://example.com/404")!
        let request = URLRequest(url: url)
        let httpOperation = HTTPRequest(request: request)

        let httpResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: ["header": "value"])
        let error = NSError(domain: "domain", code: 999, userInfo: nil)
        httpOperation.setResponse(HTTPResponse.failure(response: httpResponse, error: error))
        return httpOperation
    }

    static var failedRequest: HTTPRequest {
        let url = URL(string: "https://example.com/error")!
        let request = URLRequest(url: url)
        let httpOperation = HTTPRequest(request: request)

        let error = NSError(domain: "domain", code: 999, userInfo: nil)
        httpOperation.setResponse(HTTPResponse.failure(response: nil, error: error))
        return httpOperation
    }
}

// swiftlint:enable force_unwrapping
