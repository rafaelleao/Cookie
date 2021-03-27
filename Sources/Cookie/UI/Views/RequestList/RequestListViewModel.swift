import Foundation

class RequestListViewModel: ObservableObject {
    @Published var source: [RequestViewModel] = []
    @Published var title = ""
    private var requests: [(HTTPRequest, RequestViewModel)] = []
    var sendUpdates = true {
        didSet {
            if sendUpdates == true {
                update()
            }
        }
    }

    init() {
        self.searchString = ""
        loadRequests()
        Cookie.shared.internalDelegate = self
    }

    func loadRequests() {
        DispatchQueue.global().async { [self] in
            var viewModels = [RequestViewModel]()
            requests = []
            for request in Cookie.shared.requests {
                let viewModel = RequestViewModel(request: request)
                requests.append((request, viewModel))
                viewModels.append(viewModel)
            }
            DispatchQueue.main.async {
                source = viewModels
                self.updateTitle(counter: String(source.count))
            }
        }
    }

    var searchString: String {
        didSet {
            update()
        }
    }

    func clearRequests() {
        Cookie.shared.clearRequests()
        loadRequests()
    }

    func dismiss() {
        Cookie.shared.present()
    }

    private func update() {
        if !sendUpdates {
            return
        }
        DispatchQueue.global().async { [self] in
            self.requests.forEach { _, viewModel in
                viewModel.query = searchString
            }

            let (filteredRequests, counter) = filteredResults(searchString)
            let results = filteredRequests.map { $0.1 }

            DispatchQueue.main.async {
                self.source = results
                self.updateTitle(counter: counter)
            }
        }
    }

    private func updateTitle(counter: String) {
        title = "Requests \(counter)"
    }

    private func filteredResults(_ query: String?) -> ([(HTTPRequest, RequestViewModel)], String) {
        let totalCount = "\(requests.count)"
        guard !searchString.isEmpty else {
            return (requests, totalCount)
        }

        var results: [(HTTPRequest, RequestViewModel)] = []
        for request in requests {
            var urlComponents = URLComponents(url: request.0.urlRequest.url!, resolvingAgainstBaseURL: false)!
            urlComponents.query = nil
            let value = "\(urlComponents)"
            if value.lowercased().range(of: searchString.lowercased()) != nil {
                results.append(request)
            }
        }
        let counter = "\(results.count) / " + totalCount
        return (results, counter)
    }
}

extension RequestListViewModel: RequestDelegate {
    func shouldFireURLRequest(_ urlRequest: URLRequest) -> Bool {
        return true
    }

    func willFireRequest(_ httpRequest: HTTPRequest) {
        DispatchQueue.global().async { [self] in
            let viewModel = RequestViewModel(request: httpRequest, query: searchString)
            requests.insert((httpRequest, viewModel), at: 0)
            update()
        }
    }

    func didCompleteRequest(_ httpRequest: HTTPRequest) {}
}
