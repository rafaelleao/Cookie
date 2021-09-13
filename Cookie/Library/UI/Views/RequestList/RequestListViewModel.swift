import Foundation
import Core

class RequestListViewModel: ObservableObject {
    
    private var requests: [HTTPRequest] = []
    @Published var source: [HTTPRequest] = []
    
    var searchString: String? {
        didSet {
            if let query = searchString, query != "" {
                search(query)
            } else {
                clearSearch()
            }
        }
    }

    init() {
        requests = Cookie.shared.requests
        source = Cookie.shared.requests
        Cookie.shared.internalDelegate = self
    }

    private func clearSearch() {
        source = requests
    }
    
    private func search(_ query: String) {
        var results: [HTTPRequest] = []
        for request in requests {
            var urlComponents = URLComponents(url: request.urlRequest.url!, resolvingAgainstBaseURL: false)!
            urlComponents.query = nil
            let value = "\(urlComponents)"
            if value.lowercased().range(of: query) != nil {
                results.append(request)
            }
        }
        source = results
    }
    
    func clearRequests() {
        Cookie.shared.clearRequests()
        reloadRequests()
    }

    private func reloadRequests() {
        source = Cookie.shared.requests
        requests = Cookie.shared.requests
    }
}

extension RequestListViewModel: RequestDelegate {

    func shouldFireURLRequest(_ urlRequest: URLRequest) -> Bool {
        return true
    }
    
    func willFireRequest(_ httpRequest: HTTPRequest) {
        reloadRequests()
    }
    
    func didCompleteRequest(_ httpRequest: HTTPRequest) {
        reloadRequests()
    }
}
