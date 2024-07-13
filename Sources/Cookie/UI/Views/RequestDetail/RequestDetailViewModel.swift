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
}

@available(iOS 16.0, *)
@available(macOS 13, *)
private struct SummaryTabViewModel: TabViewModel {
    let request: HTTPRequest

    var tabDescriptor: TabDescriptor {
        .init(
            name: "Summary",
            image: "network"
        )
    }

    var view: SectionedList {
        .init(
            viewModel: .init(
                descriptor: SummaryTabDescriptor(request: request)
            )
        )
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
private struct RequestTabViewModel: TabViewModel {
    let request: HTTPRequest

    var tabDescriptor: TabDescriptor {
        .init(
            name: "Request",
            image: "icloud.and.arrow.up"
        )
    }

    var view: SectionedList {
        .init(
            viewModel: .init(
                descriptor: RequestTabDescriptor(request: request)
            )
        )
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
private struct ResponseTabViewModel: TabViewModel {
    let request: HTTPRequest

    var tabDescriptor: TabDescriptor {
        .init(
            name: "Response",
            image: "icloud.and.arrow.down"
        )
    }

    var view: SectionedList {
        .init(
            viewModel: .init(
                descriptor: ResponseTabDescriptor(request: request)
            )
        )
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
private struct WebSocketTabViewModel: TabViewModel {
    let request: HTTPRequest

    var tabDescriptor: TabDescriptor {
        .init(
            name: "WebSocket",
            image: "app.connected.to.app.below.fill"
        )
    }

    var view: some View {
        WebSocketTab(
            viewModel: .init(request: request)
        )
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
            if let newSelection = viewModels.first { $0.tabDescriptor.name == segmentationSelection } {
                selectedViewModel = newSelection
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

        // swiftlint:disable force_unwrapping
        let viewModels = [
            SummaryTabViewModel(request: request),
            RequestTabViewModel(request: request),
            ResponseTabViewModel(request: request),
            WebSocketTabViewModel(request: request)
        ] as [any TabViewModel]
        self.viewModels = viewModels
        self.selectedViewModel = viewModels.first!
        self.segmentationSelection = viewModels.first!.tabDescriptor.name

//        viewModels.forEach { $0.delegate = self }

//        $searchText.sink { newValue in
//            self.childViewModels.forEach { viewModel in
//                viewModel.searchText = newValue
//            }
//        }
//        .store(in: &bindings)
    }

//    func viewModel(title: String) -> SectionedListViewModel? {
//        nil
////        childViewModels.first { $0.title == title }
//    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
extension RequestDetailViewModel: RequestDetailTabViewModelDelegate {
    func showText(viewModel: TextViewerViewModel) {}
}
