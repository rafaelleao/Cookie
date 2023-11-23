import Foundation

@available(iOS 16.0, *)
@available(macOS 13, *)
@MainActor
protocol RequestListViewModel: ObservableObject {
    var source: [RequestViewModel] { get }
    var requestToolbarViewModel: RequestToolbarViewModel { get set }
    var searchString: String { get set }

    func clearRequests() async
    func dismiss()
}

@available(iOS 16.0, *)
@available(macOS 13, *)
typealias Domain = AttributedString

@available(iOS 16.0, *)
@available(macOS 13, *)
protocol RequestToolbarViewModelDelegate: AnyObject {
    func requestToolbarViewModel(_ viewModel: RequestToolbarViewModel, didSelectDomain domain: String?)
}

@available(iOS 16.0, *)
@available(macOS 13, *)
@MainActor
class RequestToolbarViewModel: ObservableObject {
    var selectedDomains: Set<Domain> = [] {
        didSet {
            var domain: String?
            if let selectedDomain = selectedDomains.first {
                domain = String(selectedDomain.characters)
            }
            delegate?.requestToolbarViewModel(self, didSelectDomain: domain)
        }
    }

    weak var delegate: RequestToolbarViewModelDelegate?
    var domainsSet: Set<String> = []
    var domains: [Domain] {
        var container = AttributeContainer()
        container.font = .boldSystemFont(ofSize: 14)
        var items = Array(domainsSet)
        if !toolbarFilter.isEmpty {
            items = items.filter { $0.lowercased().range(of: toolbarFilter) != nil }
        }
        return items.sorted(by: <).map {
            AttributedString($0, highlightedString: toolbarFilter, attributeContainer: container)
        }
    }

    var toolbarFilter: String = "" {
        didSet {
            objectWillChange.send()
        }
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
@MainActor
final class RequestListViewModelImpl: RequestListViewModel {
    let requestRepository: RequestRepository

    @Published private(set) var source: [RequestViewModel] = []
    @Published private(set) var title = ""
    @Published var requestToolbarViewModel: RequestToolbarViewModel = RequestToolbarViewModel()

    var searchString: String = "" {
        didSet {
            Task {
                await requestFilter.setSearchString(searchString)
            }
        }
    }

    private let requestFilter: RequestFilter = .init()

    init(requestRepository: RequestRepository) {
        self.requestRepository = requestRepository
        requestToolbarViewModel.delegate = self
        Task {
            await setupFilter()
        }
    }

    func clearRequests() async {
        await requestRepository.clearRequests()
        await setupFilter()
    }

    func dismiss() {
        Cookie.shared.present()
    }

    private func setupFilter() async {
        await requestRepository.setDelegate(self)
        await requestFilter.setDelegate(delegate: self)
        await requestFilter.setRequests(httpRequests: requestRepository.requests)
    }

    private func publishUpdate(requests: [RequestViewModel], counter: String) {
        requests.forEach {
            if let domain = $0.request.domain {
                requestToolbarViewModel.domainsSet.insert(domain)
            }
        }
        source = requests
        title = "Requests \(counter)"
    }
}

@available(macOS 13, *)
@available(iOS 16.0, *)
extension RequestListViewModelImpl: RequestRepositoryDelegate {
    func requestRepository(_ requestRepository: RequestRepository, didAddRequest httpRequest: HTTPRequest) {
        Task {
            await requestFilter.prepend(httpRequest: httpRequest)
            if let domain = httpRequest.domain {
                assert(httpRequest.urlRequest.url?.host() == domain)
                requestToolbarViewModel.domainsSet.insert(domain)
            }
        }
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
extension RequestListViewModelImpl: RequestFilterDelegate {
    func didUpdateResults(_ viewModels: [RequestViewModel], filteredCount: Int) {
        let totalCount = "\(viewModels.count + filteredCount)"
        let counter = filteredCount == 0 ? totalCount : "\(viewModels.count) / " + totalCount
        publishUpdate(requests: viewModels, counter: counter)
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
extension RequestListViewModelImpl: RequestToolbarViewModelDelegate {
    func requestToolbarViewModel(_ viewModel: RequestToolbarViewModel, didSelectDomain domain: String?) {
        Task {
            await requestFilter.setDomain(domain)
        }
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
@MainActor
private protocol RequestFilterDelegate: AnyObject {
    func didUpdateResults(_ viewModels: [RequestViewModel], filteredCount: Int)
}

@available(iOS 16.0, *)
@available(macOS 13, *)
private actor RequestFilter {
    private var requestMap: [(HTTPRequest, RequestViewModel)] = []
    private(set) var searchString: String = ""
    private(set) var domain: String?
    private(set) weak var delegate: RequestFilterDelegate?

    func setDelegate(delegate: RequestFilterDelegate?) {
        self.delegate = delegate
    }

    func setSearchString(_ searchString: String) async {
        self.searchString = searchString
        await filterResults()
    }

    func setDomain(_ domain: String?) async {
        self.domain = domain
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
        guard !searchString.isEmpty || domain != nil else {
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

            if let domain {
                if domain != request.0.domain {
                    continue
                }
            }

            if !searchString.isEmpty {
                urlComponents.query = nil
                let value = "\(urlComponents)"
                if value.lowercased().range(of: searchString.lowercased()) == nil {
                    continue
                }
            }

            results.append(request.1)
            await request.1.updateQuery(searchString)
        }
        await delegate?.didUpdateResults(results, filteredCount: requestMap.count - results.count)
    }
}
