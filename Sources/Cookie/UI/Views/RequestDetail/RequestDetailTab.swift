import Combine
import SwiftUI

@available(macOS 13, *)
struct RequestDetailTab: View, Identifiable {
    var id = UUID()
    @ObservedObject var viewModel: RequestDetailTabViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
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

            if let textViewerViewModel = viewModel.textViewerViewModel {
                TextViewer(viewModel: textViewerViewModel)
            }
        }
//        .searchable(text: $viewModel.searchText, prompt: "Search")
        .tabItem {
            Image(systemName: viewModel.image)
            Text(viewModel.title)
        }
//        .listStyle(GroupedListStyle())
    }
}

@available(macOS 13, *)
struct RequestDetailTab_Previews: PreviewProvider {
    static let request = TestRequest.completedTestRequest

    private static func makeSummaryPreview() -> some View {
        let descriptor = SummaryTabDescriptor(request: request)
        let viewModel = RequestDetailTabViewModel(descriptor: descriptor)
        return RequestDetailTab(viewModel: viewModel)
    }

    private static func makeRequestPreview() -> some View {
        let descriptor = RequestTabDescriptor(request: request)
        let viewModel = RequestDetailTabViewModel(descriptor: descriptor)
        return RequestDetailTab(viewModel: viewModel)
    }

    private static func makeResponsePreview() -> some View {
        let descriptor = ResponseTabDescriptor(request: request)
        let viewModel = RequestDetailTabViewModel(descriptor: descriptor)
        viewModel.action = Action(title: "Show Response", handler: {
            TextViewerViewModel(text: "Test", filename: "Response")
        })
        return RequestDetailTab(viewModel: viewModel)
    }

    static var previews: some View {
        Group {
            makeSummaryPreview()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Summary")
            makeRequestPreview()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Request")
            makeResponsePreview()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Response")
        }
    }
}
