import Combine
import Networking
import SwiftUI

struct TabDescriptor: Identifiable {
    let name: String
    let image: String
    var id: String { name }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
private protocol TabViewModel {
    associatedtype SomeView: View

    var tabDescriptor: TabDescriptor { get }
    var view: SomeView { get }
    var searchText: String { get set }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
private class SummaryTabViewModel: TabViewModel {
    let request: HTTPRequest
    private lazy var viewModel: SectionedListViewModel = .init(descriptor: SummaryTabDescriptor(request: request))

    init(request: HTTPRequest) {
        self.request = request
    }

    var tabDescriptor: TabDescriptor {
        .init(
            name: "Summary",
            image: "network"
        )
    }

    var view: SectionedList {
        .init(
            viewModel: viewModel
        )
    }

    var searchText: String = "" {
        didSet {
            viewModel.searchText = searchText
        }
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
private class RequestTabViewModel: TabViewModel {
    let request: HTTPRequest
    private lazy var viewModel: SectionedListViewModel = .init(descriptor: RequestTabDescriptor(request: request))

    init(request: HTTPRequest) {
        self.request = request
    }

    var tabDescriptor: TabDescriptor {
        .init(
            name: "Request",
            image: "icloud.and.arrow.up"
        )
    }

    var view: SectionedList {
        .init(
            viewModel: viewModel
        )
    }

    var searchText: String = "" {
        didSet {
            viewModel.searchText = searchText
        }
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
private class ResponseTabViewModel: TabViewModel {
    let request: HTTPRequest
    private lazy var viewModel: SectionedListViewModel = .init(descriptor: ResponseTabDescriptor(request: request))

    init(request: HTTPRequest) {
        self.request = request
    }

    var tabDescriptor: TabDescriptor {
        .init(
            name: "Response",
            image: "icloud.and.arrow.down"
        )
    }

    var view: SectionedList {
        .init(
            viewModel: viewModel
        )
    }

    var searchText: String = "" {
        didSet {
            viewModel.searchText = searchText
        }
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
private class WebSocketTabViewModel: TabViewModel {
    let request: HTTPRequest
    private lazy var viewModel: WebSocketViewModel = .init(request: request)

    init(request: HTTPRequest) {
        self.request = request
    }

    var tabDescriptor: TabDescriptor {
        .init(
            name: "WebSocket",
            image: "app.connected.to.app.below.fill"
        )
    }

    var view: some View {
        WebSocketTab(viewModel: viewModel)
    }

    var searchText: String = "" {
        didSet {
            viewModel.searchText = searchText
        }
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
class RequestDetailViewModel: ObservableObject {
    let request: HTTPRequest
    @Published var searchText: String = ""
    private var bindings: [AnyCancellable] = []

    var title: String {
        request.urlRequest.url?.host ?? "Request Details"
    }

    private let viewModels: [any TabViewModel]
    private var selectedViewModel: any TabViewModel

    var segmentationSelection: String {
        didSet {
            if let newSelection = viewModels.first(where: { $0.tabDescriptor.name == segmentationSelection }) {
                selectedViewModel = newSelection
                selectedViewModel.searchText = searchText
                objectWillChange.send()
            }
        }
    }

    var contentView: some View {
        AnyView(selectedViewModel.view)
    }

    var tabDescriptors: [TabDescriptor] {
        viewModels.map { $0.tabDescriptor }
    }

    init(request: HTTPRequest) {
        self.request = request

        let viewModels = [
            SummaryTabViewModel(request: request),
            RequestTabViewModel(request: request),
            ResponseTabViewModel(request: request),
            WebSocketTabViewModel(request: request)
        ] as [any TabViewModel]
        self.viewModels = viewModels
        guard let viewModel = viewModels.first else {
            fatalError("Unexpected empty array")
        }
        self.selectedViewModel = viewModel
        self.segmentationSelection = viewModel.tabDescriptor.name

        $searchText.sink { [weak self] newValue in
            self?.selectedViewModel.searchText = newValue
        }
        .store(in: &bindings)
    }
}
