import Foundation
import SwiftUI
import Combine

class RequestViewModel: ObservableObject/*, SearchableListItem*/ {

    let request: HTTPRequest
    private var bindings: [AnyCancellable] = []

    init(request: HTTPRequest) {
        self.request = request
        
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
