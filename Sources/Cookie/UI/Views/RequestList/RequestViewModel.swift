import Combine
import Foundation
import SwiftUI

@MainActor
class RequestViewModel: ObservableObject {
    let request: HTTPRequest
    private var bindings: [AnyCancellable] = []
    private(set) var query: String {
        didSet {
            if query != oldValue {
                self.objectWillChange.send()
            }
        }
    }

    init(request: HTTPRequest, query: String = "") {
        self.request = request
        self.query = query

        request.$response
            .receive(on: RunLoop.main)
            .sink { _ in
                self.objectWillChange.send()
            }
            .store(in: &bindings)
    }

    func updateQuery(_ query: String) {
        self.query = query
    }

    var value: String {
        var urlComponents = URLComponents(url: request.urlRequest.url!, resolvingAgainstBaseURL: false)!
        urlComponents.query = nil
        return "\(urlComponents)"
    }

    @available(iOS 15, *)
    var attributedValue: AttributedString {
        var attributedString = NSAttributedString(string: "\(value)")
        if !query.isEmpty {
            attributedString = attributedString.highlight(query, highlightedTextColor: .orange)
        }
        return AttributedString(attributedString)
    }

    var key: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        let date = dateFormatter.string(from: request.requestDate)
        return date
    }

    var method: String? {
        String(request.urlRequest.httpMethod ?? "")
    }

    var isLoading: Bool {
        if case .loading = requestStatus {
            return true
        }
        return false
    }

    private var requestStatus: RequestStatus? {
        if let statusCode = statusCode {
            return .completed(statusCode: statusCode)
        }
        if error != nil {
            return .error
        }
        return .loading
    }

    var contentType: String? {
        request.contentType
    }

    var result: (String, Color)? {
        if let code = statusCode {
            let color = (code >= 200 && code < 300) ? Color.green : Color.red
            return ("\(code)", color)
        }
        if error != nil {
            return ("Error", Color.red)
        }
        return nil
    }

    private var statusCode: Int? {
        if case let .success(request, _) = request.response {
            return request.statusCode
        } else if case let .failure(request, _) = request.response {
            return request?.statusCode
        }
        return nil
    }

    private var error: Error? {
        if case let .failure(_, error) = request.response {
            return error
        }
        return nil
    }
}

extension RequestViewModel: Identifiable {}
