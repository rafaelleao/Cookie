import Foundation

class RequestListViewModel: ObservableObject {
    
    @Published var source: [HTTPRequest] = []

    init() {
        source = Cookie.shared.requests
        Cookie.shared.internalDelegate = self
    }

    func clearRequest() {
        Cookie.shared.clearRequests()
        reloadRequests()
    }

    private func reloadRequests() {
        source = Cookie.shared.requests
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
