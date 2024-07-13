import Combine
import Networking
import SwiftUI

@available(iOS 16.0, *)
@available(macOS 13, *)
struct SectionedList: View, Identifiable {
    private(set) var id = UUID()
    @ObservedObject var viewModel: SectionedListViewModel

    init(viewModel: SectionedListViewModel) {
        self.viewModel = viewModel
    }

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
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
struct RequestDetailTab_Previews: PreviewProvider {
    static let request = TestRequest.completedTestRequest

    private static func makeSummaryPreview() -> some View {
        let descriptor = SummaryTabDescriptor(request: request)
        let viewModel = SectionedListViewModel(descriptor: descriptor)
        return SectionedList(viewModel: viewModel)
    }

    private static func makeRequestPreview() -> some View {
        let descriptor = RequestTabDescriptor(request: request)
        let viewModel = SectionedListViewModel(descriptor: descriptor)
        return SectionedList(viewModel: viewModel)
    }

    private static func makeResponsePreview() -> some View {
        let descriptor = ResponseTabDescriptor(request: request)
        let viewModel = SectionedListViewModel(descriptor: descriptor)
        viewModel.action = Action(title: "Show Response", handler: {
            TextViewerViewModel(text: "Test", filename: "Response")
        })
        return SectionedList(viewModel: viewModel)
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

@available(macOS 10.15, *)
extension Dictionary {
    func toJsonString() -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed),
              let jsonString = jsonData.toJsonString()
        else {
            fatalError("Cannot convert dictionary to data")
        }
        return jsonString
    }
}
