import SwiftUI

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

    var body: some View {
        if #available(iOS 15.0, *) {
            NavigationView {
                list
                    .searchable(text: $viewModel.searchString, placement: .navigationBarDrawer(displayMode: .always))
                    .autocapitalization(.none)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .edgesIgnoringSafeArea(.top)
        } else {
            SearchNavigation(text: $searchString, textChanged: textChanged, search: search, cancel: cancel) {
                list
            }
            .edgesIgnoringSafeArea(.top)
        }
    }

    private var list: some View {
        List {
            Section(header: Text(viewModel.title)) {
                ForEach(viewModel.source) { requestViewModel in
                    NavigationLink(destination: NavigationLazyView(
                        RequestDetail(viewModel: RequestDetailViewModel(request: requestViewModel.request), onDismiss: {
                            viewModel.sendUpdates = true
                        })
                        .onAppear {
                            viewModel.sendUpdates = false
                        }
                    )) {
                        RequestRow(viewModel: requestViewModel)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Cookie", displayMode: .inline)
        .navigationBarItems(
            leading: Button(action: {
                viewModel.dismiss()
            }, label: {
                Image(systemName: "xmark")
            }),
            trailing: HStack {
//                Button(action: {
//                    viewModel.clearRequests()
//                }, label: {
//                    Image(systemName: "gearshape")
//                })
                Spacer(minLength: 20.0)
                Button(action: {
                    viewModel.clearRequests()
                }, label: {
                    Image(systemName: "trash")
                })
            }
        )
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
