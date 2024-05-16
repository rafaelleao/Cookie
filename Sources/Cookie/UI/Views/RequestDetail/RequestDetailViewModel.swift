import Combine

@available(iOS 16.0, *)
@available(macOS 13, *)
class RequestDetailViewModel: ObservableObject {
    let request: HTTPRequest
    @Published var searchText: String = ""
    private var bindings: [AnyCancellable] = []

    var title: String {
        request.urlRequest.url?.host ?? "Request Details"
    }

    let tabDescriptors: [TabDescriptor]
    var childViewModels: [RequestDetailTabViewModel]
    var childViewModel: RequestDetailTabViewModel
    var segmentationSelection: String {
        didSet {
            if let viewModel = viewModel(title: segmentationSelection) {
                childViewModel = viewModel
                objectWillChange.send()
            }
        }
    }

    init(request: HTTPRequest) {
        self.request = request
        let descriptors: [TabDescriptor] = [
            SummaryTabDescriptor(request: request),
            RequestTabDescriptor(request: request),
            ResponseTabDescriptor(request: request),
            WebSocketTabDescriptor(request: request),
        ]
        self.tabDescriptors = descriptors
        // swiftlint:disable force_unwrapping
        self.segmentationSelection = descriptors.first!.title
        let viewModels = descriptors.map {
            RequestDetailTabViewModel(descriptor: $0)
        }
        self.childViewModels = viewModels
        self.childViewModel = viewModels.first!
        // swiftlint:enable force_unwrapping

        viewModels.forEach { $0.delegate = self }

        $searchText.sink { newValue in
            self.childViewModels.forEach { viewModel in
                viewModel.searchText = newValue
            }
        }
        .store(in: &bindings)
    }

    func viewModel(title: String) -> RequestDetailTabViewModel? {
        childViewModels.first { $0.title == title }
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
extension RequestDetailViewModel: RequestDetailTabViewModelDelegate {
    func showText(viewModel: TextViewerViewModel) {}
}
