import SwiftUI

@available(macOS 13, *)
struct RequestList<ViewModel: RequestListViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var selectedDomains: Set<String> = []
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
        List(viewModel.domains, id: \.self, selection: $viewModel.selectedDomains) { domain in
            Text(domain)
        }
    }

    private var list: some View {
        List(viewModel.source) { requestViewModel in
            RequestRow(viewModel: requestViewModel)
                .listRowBackground(requestViewModel.request == selectedRequest ? Color.accentColor : nil)
                .onTapGesture {
                    selectedRequest = requestViewModel.request
                }
        }
        #if os(iOS)
        .autocapitalization(.none)
        .toolbar(content: {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: {
                    viewModel.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            }

            ToolbarItemGroup(placement: .navigation) {
                Spacer(minLength: 20.0)
                Button(action: {
                    viewModel.clearRequests()
                }, label: {
                    Image(systemName: "trash")
                })
            }
        })
        #endif
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

@available(macOS 13, *)
class RequestListViewModelMock: RequestListViewModel {
    var selectedDomains: Set<String> = []
    var source: [RequestViewModel]
    var domains: [String]
    var searchString: String
    var textViewModel: TextViewerViewModel?

    init(source: [RequestViewModel], searchString: String = "") {
        self.source = source
        self.searchString = searchString
        self.domains = Array(Set(source.compactMap { $0.request.domain }))
    }

    func clearRequests() {
        source.removeAll()
        objectWillChange.send()
    }

    func dismiss() {}
}

@available(macOS 13, *)
struct RequestList_Previews: PreviewProvider {
    private static func makePreview() -> some View {
        let source = [
            TestRequest.testRequest,
            TestRequest.completedTestRequest,
            TestRequest.serverErrorRequest,
            TestRequest.failedRequest,
        ].map { RequestViewModel(request: $0) }
        let viewModel = RequestListViewModelMock(
            source: source)
        return RequestList(viewModel: viewModel)
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
