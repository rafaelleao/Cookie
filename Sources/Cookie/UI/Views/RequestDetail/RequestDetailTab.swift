import SwiftUI
import Combine

struct RequestDetailTab: View, Identifiable {
    var id = UUID()
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
                            let viewModel = RequestDetailRowViewModel(pair: pair, searchText: viewModel.searchText)
                            RequestDetailRow(viewModel: viewModel)
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

struct RequestDetailTab_Previews: PreviewProvider {
    
    static let request = TestRequest.testRequest
    
    static private func makeSummaryPreview() -> some View {
        let descriptor = SummaryTabDescriptor(request: request)
        let viewModel = RequestDetailTabViewModel(descriptor: descriptor)
        return RequestDetailTab(viewModel: viewModel)
    }
    
    static private func makeRequestPreview() -> some View {
        let descriptor = RequestTabDescriptor(request: request)
        let viewModel = RequestDetailTabViewModel(descriptor: descriptor)
        return RequestDetailTab(viewModel: viewModel)
    }
    
    static private func makeResponsePreview() -> some View {
        let descriptor = ResponseTabDescriptor(request: request)
        let viewModel = RequestDetailTabViewModel(descriptor: descriptor)
        return RequestDetailTab(viewModel: viewModel)
    }

    static var previews: some View {
        Group {
            makeSummaryPreview()
                .previewLayout(.sizeThatFits)
            makeRequestPreview()
                .previewLayout(.sizeThatFits)
            makeResponsePreview()
                .previewLayout(.sizeThatFits)
        }
    }
}
