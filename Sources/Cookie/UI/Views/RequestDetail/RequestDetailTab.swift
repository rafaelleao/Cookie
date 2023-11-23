import Combine
import SwiftUI

@available(iOS 16.0, *)
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

            #if os(iOS)
            if let action = viewModel.action {
                NavigationLink(destination:
                    TextViewer(viewModel: action.handler())
                ) {
                    Text(action.title)
                        .bold()
                }
                .padding()
                .searchable(text: $viewModel.searchText, prompt: "Search")
            }
            #else
            if let textViewerViewModel = viewModel.textViewerViewModel {
                TextViewer(viewModel: textViewerViewModel)
            }
            #endif
        }
        .tabItem {
            Image(systemName: viewModel.image)
            Text(viewModel.title)
        }
    }
}

@available(iOS 16.0, *)
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
            NavigationStack {
                makeSummaryPreview()
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Summary")

            NavigationStack {
                makeRequestPreview()
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Request")

            NavigationStack {
                makeResponsePreview()
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Response")
        }
    }
}
