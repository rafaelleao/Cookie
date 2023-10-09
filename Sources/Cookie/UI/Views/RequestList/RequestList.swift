import SwiftUI

extension View {
  @inlinable
  func modify<T: View>(@ViewBuilder modifier: ( Self ) -> T) -> T {
      modifier(self)
  }
}

struct RequestList: View {
    @ObservedObject var viewModel: RequestListViewModel
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
//        #if os(iOS)
//        NavigationStack {
//            list
//        }
//        #else
        NavigationSplitView(
            sidebar: {
                list
                    .searchable(text: $viewModel.searchString, placement: .sidebar)
        }
//            , content: {
//                list
//                    .searchable(text: $viewModel.searchString, placement: .toolbar)
//
//        }
            , detail: {
                if let selectedRequest {
                    RequestDetail(viewModel: RequestDetailViewModel(request: selectedRequest))
                } else {
                    EmptyView()
                }
        })
//        #endif

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
//        List {
//            Section(header: Text(viewModel.title)) {
//                ForEach(viewModel.source) { requestViewModel in
//                    NavigationLink(destination: NavigationLazyView(
//                        RequestDetail(viewModel: RequestDetailViewModel(request: requestViewModel.request), onDismiss: {
//                            viewModel.sendUpdates = true
//                        })
//                        .onAppear {
//                            viewModel.sendUpdates = false
//                        }
//                    )) {
//                        RequestRow(viewModel: requestViewModel)
//                    }
//                }
//            }
//        }
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
//        .modify {
//            #if os(iOS)
//            $0.searchable(text: $viewModel.searchString, placement: .navigationBarDrawer(displayMode: .always))
//            #else
//            $0.searchable(text: $viewModel.searchString, placement: .automatic)
//            #endif
//
//        }
    }
}

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}

struct RequestList_Previews: PreviewProvider {
    private static func makePreview() -> some View {
        let viewModel = RequestListViewModel()

        viewModel.source = [
            TestRequest.testRequest,
            TestRequest.completedTestRequest,
            TestRequest.serverErrorRequest,
            TestRequest.failedRequest
        ].map { RequestViewModel(request: $0) }
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
