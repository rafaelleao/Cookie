import Combine
import Foundation
import Networking

struct SectionData {
    let title: String
    let pairs: [KeyValuePair]
}

extension SectionData: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
protocol RequestDetailTabViewModelDelegate: AnyObject {
    func showText(viewModel: TextViewerViewModel)
}

@available(iOS 16.0, *)
@available(macOS 13, *)
protocol SectionedListDescriptor {
    init(request: HTTPRequest)
    var request: HTTPRequest { get }
    var title: String { get }
    var image: String { get }
    var textViewerViewModel: TextViewerViewModel? { get }
    func sections() -> [SectionData]
    func action() -> Action?
    func websocketList() -> [WebsocketListItemViewModel]?
}

@available(iOS 16.0, *)
@available(macOS 13, *)
extension SectionedListDescriptor {
    func websocketList() -> [WebsocketListItemViewModel]? {
        nil
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
class Action {
    let title: String
    let handler: () -> TextViewerViewModel

    init(title: String, handler: @escaping (() -> TextViewerViewModel)) {
        self.title = title
        self.handler = handler
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
class SectionedListViewModel: ObservableObject {
    weak var delegate: RequestDetailTabViewModelDelegate?
    @Published var data: [SectionData] = []
    @Published var searchText: String = ""
    @Published var action: Action?
    @Published var isLoading: Bool
    private(set) var title: String
    private(set) var image: String
    private(set) var textViewerViewModel: TextViewerViewModel?

    private var sections: [SectionData]
    private var bindings: [AnyCancellable] = []

    @Published var websocketListItems: [WebsocketListItemViewModel]?

    init(descriptor: SectionedListDescriptor) {
        self.websocketListItems = descriptor.websocketList()
        self.sections = descriptor.sections()
        self.action = descriptor.action()
        self.title = descriptor.title
        self.image = descriptor.image
        self.isLoading = descriptor.request.response == nil
        self.textViewerViewModel = descriptor.textViewerViewModel
        if isLoading {
            descriptor.request.$response
                .receive(on: RunLoop.main)
                .dropFirst()
                .sink { _ in
                    self.isLoading = false
                    self.sections = descriptor.sections()
                    self.filter(searchString: self.searchText)
                }
                .store(in: &bindings)
        }
        $searchText.sink { [unowned self] text in
            print(text)
            filter(searchString: text)
        }
        .store(in: &bindings)
    }

    func actionClicked() {
        if let action, let delegate {
            let viewModel = action.handler()
            delegate.showText(viewModel: viewModel)
        }
    }

    private func filter(searchString: String) {
        if searchString.isEmpty {
            data = sections
            return
        }
        var results: [SectionData] = []
        for section in sections {
            var pairs: [KeyValuePair] = []
            for pair in section.pairs {
                if pair.key.contains(searchString) || pair.value?.contains(searchString) ?? false {
                    pairs.append(pair)
                }
            }
            let section = SectionData(title: section.title, pairs: pairs)
            results.append(section)
        }
        data = results
    }
}
