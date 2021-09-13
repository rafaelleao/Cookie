import SwiftUI
import Core

extension HTTPRequest: Identifiable {

}

struct RequestList: View {
    @ObservedObject var viewModel: RequestListViewModel
    @State var searchString = ""

    func textChanged() {
        viewModel.searchString = searchString
    }
    
    func search() {
    }

    func cancel() {
        viewModel.searchString = nil
    }
     
    var body: some View {
        SearchNavigation(text: $searchString, textChanged: textChanged, search: search, cancel: cancel) {
            List(viewModel.source) { request in
                NavigationLink(destination: RequestDetail(viewModel: RequestDetailViewModel(request: request))) {
                    RequestRow(viewModel: RequestViewModel(request: request))
                }
                //.background(Color(.secondarySystemBackground))
                //.cornerRadius(8)
            }
             .listStyle(GroupedListStyle())
            .navigationBarTitle("Requests", displayMode: .inline)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct Requests_Previews: PreviewProvider {
    static private func makePreview() -> some View {
        let viewModel = RequestListViewModel()

        viewModel.source = [
            TestRequest.testRequest,
            TestRequest.completedTestRequest,
            TestRequest.serverErrorRequest,
            TestRequest.failedRequest
        ]
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
