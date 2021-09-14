import SwiftUI

struct RequestDetailTabRequest: View {
    @ObservedObject var viewModel: RequestDetailTabViewModel
    
    var body: some View {
        VStack {
            SearchBar(text: $viewModel.searchText, placeholder: "Search")
            
            if let action = viewModel.action {
                NavigationLink(destination: TextViewer(viewModel: action.handler())) {
                    Text(action.title)
                        .padding()
                }
            }
            
            List {
                ForEach(viewModel.data, id: \.self) { row in
                    Section(header: Text(row.title)) {
                        ForEach(row.pairs, id: \.key) { pair in
                            RequestDetailItem(pair: pair)
                        }
                    }
                }
            }
        }.tabItem {
            Text(viewModel.title)
        }
        .listStyle(GroupedListStyle())
    }
}

struct RequestDetailTabRequest_Previews: PreviewProvider {
    static var previews: some View {
        let descriptor = SummaryTabDescriptor(request: TestRequest.testRequest)
        let viewModel = RequestDetailTabViewModel(descriptor: descriptor)
        RequestDetailTabRequest(viewModel: viewModel)
    }
}
