import Networking
import SwiftUI

@available(iOS 16.0, *)
@available(macOS 13, *)
struct RequestList<ViewModel: RequestListViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var selectedRequest: HTTPRequest? {
        didSet {
            makeRequestDetailViewModelIfNeeded()
        }
    }

    @State private var requestDetailViewModel: RequestDetailViewModel?
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly

    var body: some View {
        #if os(iOS)
        NavigationStack {
            list
                .navigationDestination(isPresented: .constant(selectedRequest != nil), destination: {
                    detail
                })
        }
        #else
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            sidebar: {
                sidebar
                    .navigationSplitViewColumnWidth(ideal: 250, max: 400)
            },
            content: {
                list
                    .navigationSplitViewColumnWidth(min: 350, ideal: 450, max: 550)
            },
            detail: {
                detail
            }
        )
        .navigationSplitViewStyle(.prominentDetail)
        .onAppear(perform: {
            columnVisibility = selectedRequest != nil ? .all : .detailOnly
        })
        #endif
    }

    private var sidebar: some View {
        VStack(alignment: .leading, content: {
            HStack {
                Label("Domains", systemImage: "chevron.down")
                Text("\(viewModel.requestToolbarViewModel.domains.count)")
                    .bold()
                    .foregroundColor(.white)
                    .modifier(RoundedLabel(backgroundColor: .gray))
            }.onTapGesture {
                viewModel.requestToolbarViewModel.selectedDomains = []
            }
            List(viewModel.requestToolbarViewModel.domains, id: \.self, selection: $viewModel.requestToolbarViewModel.selectedDomains) { domain in
                Text(domain)
            }
            SearchBar(placeholder: "Filter", text: $viewModel.requestToolbarViewModel.toolbarFilter)
        })
        .padding(8)
    }

    private var list: some View {
        List(viewModel.source) { requestViewModel in
            RequestRow(viewModel: requestViewModel)
            #if os(macOS)
                .listRowBackground(requestViewModel.request == selectedRequest ? Color.accentColor : nil)
            #endif
                .onTapGesture {
                    selectedRequest = requestViewModel.request
                }
        }
        #if os(iOS)
        .autocapitalization(.none)
        #endif

        .toolbar(content: {
            #if os(iOS)
            ToolbarItemGroup(placement: .navigation) {
                Button(action: {
                    viewModel.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            }
            #endif

            ToolbarItemGroup(placement: .navigation) {
                Spacer(minLength: 20.0)
                Button(action: {
                    Task {
                        await viewModel.clearRequests()
                    }
                }, label: {
                    Image(systemName: "trash")
                })
            }
        })
        .searchable(text: $viewModel.searchString, placement: .automatic)
    }

    private var detail: some View {
        Group {
            if let requestDetailViewModel {
                RequestDetail(viewModel: requestDetailViewModel)
            } else {
                EmptyView()
            }
        }
    }

    private func makeRequestDetailViewModelIfNeeded() {
        guard let selectedRequest else {
            requestDetailViewModel = nil
            return
        }
        if requestDetailViewModel?.request != selectedRequest {
            requestDetailViewModel = RequestDetailViewModel(request: selectedRequest)
        }
    }
}

#if DEBUG

@available(iOS 16.0, *)
@available(macOS 13, *)
class RequestListViewModelMock: RequestListViewModel {
    var requestToolbarViewModel: RequestToolbarViewModel = RequestToolbarViewModel()
    var source: [RequestViewModel]
    var searchString: String
    var textViewModel: TextViewerViewModel?

    init(source: [RequestViewModel], searchString: String = "") {
        self.source = source
        self.searchString = searchString
    }

    func clearRequests() {
        source.removeAll()
        objectWillChange.send()
    }

    func dismiss() {}
}

@available(iOS 16.0, *)
@available(macOS 13.0, *)
final actor RequestRepositoryMock: RequestRepository {
    var requests: [HTTPRequest] = []

    func setRequests(_ requests: [HTTPRequest]) async {
        self.requests = requests
    }

    func setDelegate(_ delegate: RequestRepositoryDelegate) {}

    func clearRequests() {}
}

@available(iOS 16.0, *)
@available(macOS 13, *)
struct RequestList_Previews: PreviewProvider {
    static let requests = [
        TestRequest.testRequest,
        TestRequest.completedTestRequest,
        TestRequest.serverErrorRequest,
        TestRequest.failedRequest,
    ]

    @available(iOS 16.0, *)
    private static func makePreview() -> some View {
        RequestList(viewModel: makeViewModel())
    }

    private static func makeViewModel() -> some RequestListViewModel {
        #if os(iOS)
        let repository = RequestRepositoryMock()
        let viewModel = RequestListViewModelImpl(requestRepository: repository)
        Task {
            await repository.setRequests(requests)
        }
        return viewModel
        #else
        let source = requests.map { RequestViewModel(request: $0) }
        let viewModel = RequestListViewModelMock(source: source)
        requests.compactMap { $0.domain }.forEach {
            viewModel.requestToolbarViewModel.domainsSet.insert($0)
        }
        return viewModel
        #endif
    }

    static var previews: some View {
        Group {
            makePreview()
                .preferredColorScheme(.light)
            makePreview()
                .preferredColorScheme(.dark)
        }
    }
}

#endif
