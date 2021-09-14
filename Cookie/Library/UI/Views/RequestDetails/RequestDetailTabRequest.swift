import SwiftUI

struct RequestDetailTabRequest: View {
    @ObservedObject var viewModel: RequestDetailTabRequestViewModel
    
    var body: some View {
        VStack {
            SearchBar(text: viewModel.$searchText, placeholder: "Search")
            
            if viewModel.canShowRequestBody() {
                NavigationLink(destination: TextViewer(viewModel: viewModel.textViewerViewModel()!)) {
                    Text("View Request Body")
                        .padding()
                }
            }
            List {
                ForEach(viewModel.data, id: \.self) { row in
                    //if row.pairs.count > 0 {
                    Section(header: Text(row.title)) {
                        ForEach(row.pairs, id: \.key) { pair in
                            RequestDetailItem(pair: pair)
                        }
                    }
                    // }
                }
            }
        }.tabItem {
            Text("Request")
        }
        .listStyle(GroupedListStyle())
    }
}

struct RequestDetailTabRequest_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetailTabRequest(viewModel: RequestDetailTabRequestViewModel(request: TestRequest.testRequest))
    }
}
