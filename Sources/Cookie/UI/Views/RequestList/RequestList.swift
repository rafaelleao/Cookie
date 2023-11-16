import SwiftUI

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
                .searchable(text: $viewModel.searchString, placement: .automatic)
                .autocapitalization(.none)
                .navigationDestination(isPresented: .constant(selectedRequest != nil), destination: {
                    if let selectedRequest {
                        let detailViewModel = RequestDetailViewModel(request: selectedRequest)
                        RequestDetail(viewModel: detailViewModel)
                    } else {
                        EmptyView()
                    }
                })
        }
        #else
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            sidebar: {},
            content: {
                VStack {
                    list
                        .searchable(text: $viewModel.searchString, placement: .automatic)
//                      SearchBar(placeholder: "Search", text: $viewModel.searchString)
//                        .padding(.all, 8)
                }
                .navigationSplitViewColumnWidth(min: 350, ideal: 450, max: 550)
            },
            detail: {
                if let requestDetailViewModel {
                    RequestDetail(viewModel: requestDetailViewModel)
                } else {
                    EmptyView()
                }
            }
        )
        .navigationSplitViewStyle(.prominentDetail)
        .onAppear(perform: {
            columnVisibility = selectedRequest != nil ? .all : .detailOnly
        })
        #endif
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
