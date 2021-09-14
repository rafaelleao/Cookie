import Foundation
import Core

class RequestListViewModel: ObservableObject {
    
    private var requests: [HTTPRequest] = [] {
        didSet {
            update()
        }
    }
    @Published var source: [RequestViewModel] = []
    @Published var title = ""

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
        Cookie.shared.internalDelegate = self
        update()
    }
    
    private func update(requestsToFilter: [HTTPRequest]? = nil) {
        let allRequests = requestsToFilter ?? requests
        var results: [RequestViewModel] = []
        for request in allRequests {
            results.append(RequestViewModel(request: request))
        }
        
        let totalCount = "\(self.requests.count)"
        let counter = (requestsToFilter != nil) ? "\(allRequests.count) / " + totalCount : totalCount
        DispatchQueue.main.async {
            self.source = results
            self.title = "Requests \(counter)"
        }
    }

    private func clearSearch() {
        update()
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
        update(requestsToFilter: results)
    }
    
    func clearRequests() {
        Cookie.shared.clearRequests()
        reloadRequests()
    }

    private func reloadRequests() {
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
        //reloadRequests()
    }
}

extension RequestViewModel: Identifiable {
}
