import Foundation

@available(macOS 13, *)
@MainActor
protocol RequestListViewModel: ObservableObject {
    var source: [RequestViewModel] { get }
    var searchString: String { get set }

    func clearRequests()
    func dismiss()
}

@available(macOS 13, *)
@MainActor
class RequestListViewModelImpl: RequestListViewModel {
    @Published private(set) var source: [RequestViewModel] = []

    @Published private(set) var title = ""

    var searchString: String = "" {
        didSet {
            Task {
                await requestFilter.setSearchString(searchString)
            }
        }
    }

    private let requestFilter: RequestFilter = .init()

    init() {
        setupFilter()
        Cookie.shared.internalDelegate = self
    }

    func clearRequests() {
        Cookie.shared.clearRequests()
        setupFilter()
    }

    func dismiss() {
        Cookie.shared.present()
    }

    private func setupFilter() {
        Task {
            await self.requestFilter.setDelegate(delegate: self)
            await self.requestFilter.setRequests(httpRequests: Cookie.shared.requests)
        }
    }

    private func publishUpdate(requests: [RequestViewModel], counter: String) {
        source = requests
        title = "Requests \(counter)"
    }
}

@available(macOS 13, *)
extension RequestListViewModelImpl: RequestDelegate {
    func shouldFireURLRequest(_ urlRequest: URLRequest) -> Bool {
        true
    }

    func willFireRequest(_ httpRequest: HTTPRequest) {
        Task {
            await requestFilter.prepend(httpRequest: httpRequest)
        }
    }

    func didCompleteRequest(_ httpRequest: HTTPRequest) {}
}

@available(macOS 13, *)
extension RequestListViewModelImpl: RequestFilterDelegate {
    func didUpdateResults(_ viewModels: [RequestViewModel], filteredCount: Int) {
        let totalCount = "\(viewModels.count + filteredCount)"
        let counter = filteredCount == 0 ? totalCount : "\(viewModels.count) / " + totalCount
        publishUpdate(requests: viewModels, counter: counter)
    }
}

@available(macOS 13, *)
@MainActor
private protocol RequestFilterDelegate: AnyObject {
    func didUpdateResults(_ viewModels: [RequestViewModel], filteredCount: Int)
}

@available(macOS 13, *)
private actor RequestFilter {
    private var requestMap: [(HTTPRequest, RequestViewModel)] = []
    private(set) var searchString: String = ""
    private(set) weak var delegate: RequestFilterDelegate?

    func setDelegate(delegate: RequestFilterDelegate?) {
        self.delegate = delegate
    }

    func setSearchString(_ searchString: String) async {
        self.searchString = searchString
        await filterResults()
    }

    func setRequests(httpRequests: [HTTPRequest]) async {
        requestMap = []
        for httpRequest in httpRequests {
            let viewModel = await RequestViewModel(request: httpRequest)
            requestMap.append((httpRequest, viewModel))
        }
        await filterResults()
    }

    func prepend(httpRequest: HTTPRequest) async {
        let viewModel = await RequestViewModel(request: httpRequest, query: searchString)
        requestMap.insert((httpRequest, viewModel), at: 0)
        await filterResults()
    }

    private func filterResults() async {
        guard !searchString.isEmpty else {
            await delegate?.didUpdateResults(requestMap.map { $0.1 }, filteredCount: 0)
            return
        }

        var results: [RequestViewModel] = []
        for request in requestMap {
            guard let url = request.0.urlRequest.url,
                  var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else {
                continue
            }

            urlComponents.query = nil
            let value = "\(urlComponents)"
            if value.lowercased().range(of: searchString.lowercased()) != nil {
                results.append(request.1)
                await request.1.updateQuery(searchString)
            }
        }
        await delegate?.didUpdateResults(results, filteredCount: requestMap.count - results.count)
    }
}
