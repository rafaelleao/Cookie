import Foundation
import SwiftUI
import Combine

class RequestViewModel: ObservableObject/*, SearchableListItem*/ {

    let request: HTTPRequest
    private var bindings: [AnyCancellable] = []
    var query: String {
        didSet {
            if query != oldValue {
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
        }
    }

    init(request: HTTPRequest, query: String = "") {
        self.request = request
        self.query = query
        
        request.$response
            .receive(on: RunLoop.main)
            .sink { response in
                self.objectWillChange.send()
            }
        .store(in: &bindings)
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
        return String(request.urlRequest.httpMethod ?? "")
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
        if case .success(let request, _) = request.response {
            return request.statusCode
        } else if case .failure(let request, _) = request.response {
            return request?.statusCode
        }
        return nil
    }
    
    private var error: Error? {
        if case .failure(_, let error) = request.response {
            return error
        }
        return nil
    }
/*
    var customLabel: String? {
        return request.tag
    }
 */
}


private extension HTTPRequest {
    
    var contentType: String? {
        guard let headers = response?.urlResponse?.allHeaderFields,
              let contentType = headers["Content-Type"] as? String,
              let type = contentType.components(separatedBy: ";").first, !type.isEmpty
        else {
            return nil
        }

        return type
    }
}
