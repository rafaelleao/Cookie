import SwiftUI

extension View {
  @inlinable
  func modify<T: View>(@ViewBuilder modifier: ( Self ) -> T) -> T {
      modifier(self)
  }
}

@available(macOS 13, *)
struct RequestList<ViewModel: RequestListViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @State var searchString = ""

    func textChanged() {
        viewModel.searchString = searchString
    }

    func search() {}

    func cancel() {
        viewModel.searchString = ""
    }

    @State private var selectedRequest: HTTPRequest?

    var body: some View {
        #if os(iOS)
        NavigationStack {
            list
        }
        #else
        NavigationSplitView(
            sidebar: {
                list
                    .searchable(text: $viewModel.searchString, placement: .sidebar)
        }
        , content: {
            EmptyView()
        }
        , detail: {
                if let selectedRequest {
                    RequestDetail(viewModel: RequestDetailViewModel(request: selectedRequest))
                } else {
                    EmptyView()
                }
        })
        #endif

//        .navigationViewStyle(StackNavigationViewStyle())
//        .edgesIgnoringSafeArea(.top)
//        .navigationTitle("Cookie")
    }

    private var list: some View {
        List(viewModel.source) { requestViewModel in
            RequestRow(viewModel: requestViewModel)
                .onTapGesture {
//                                                viewModel.sendUpdates = false
                    selectedRequest = requestViewModel.request
                }
        }
        /*
        .modify {
            #if os(iOS)
            //                .autocapitalization(.none)

            $0.toolbar(content: {
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
         */
    }
}

@available(macOS 13, *)
class RequestListViewModelMock: RequestListViewModel {
    var source: [RequestViewModel]
    var searchString: String

    init(source: [RequestViewModel], searchString: String = "") {
        self.source = source
        self.searchString = searchString
    }

    func clearRequests() {
    }

    func dismiss() {
    }
}

@available(macOS 13, *)
struct RequestList_Previews: PreviewProvider {
    private static func makePreview() -> some View {
        let source = [
            TestRequest.testRequest,
            TestRequest.completedTestRequest,
            TestRequest.serverErrorRequest,
            TestRequest.failedRequest
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
