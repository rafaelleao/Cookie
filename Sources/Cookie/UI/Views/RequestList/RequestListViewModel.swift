import Foundation

class RequestListViewModel: ObservableObject {
    @MainActor @Published var source: [RequestViewModel] = []
    @MainActor @Published var title = ""
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
        Task.init {
            var viewModels = [RequestViewModel]()
            requests = []
            for request in Cookie.shared.requests {
                let viewModel = await RequestViewModel(request: request)
                requests.append((request, viewModel))
                viewModels.append(viewModel)
            }
            await publishUpdate(requests: viewModels, counter: String(viewModels.count))
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
        Task.init {
            for (_, viewModel) in self.requests {
                await viewModel.updateQuery(searchString)
            }

            let (filteredRequests, counter) = filteredResults(searchString)
            let results = filteredRequests.map { $0.1 }

            await publishUpdate(requests: results, counter: counter)
        }
    }

    @MainActor
    private func publishUpdate(requests: [RequestViewModel], counter: String) {
        source = requests
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
        Task.init {
            let viewModel = await RequestViewModel(request: httpRequest, query: searchString)
            requests.insert((httpRequest, viewModel), at: 0)
            update()
        }
    }

    func didCompleteRequest(_ httpRequest: HTTPRequest) {}
}
