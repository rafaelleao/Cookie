import Combine
import Networking
import SwiftUI

@available(iOS 16.0, *)
@available(macOS 13, *)
struct SectionedList: View, Identifiable {
    private(set) var id = UUID()
    @ObservedObject var viewModel: SectionedListViewModel
    @State private var selection: WebsocketListItemViewModel?

    var textViewerViewModel: TextViewerViewModel? {
        if let selection {
            let data = selection.header.data(using: .utf8)
            if let text = data?.toJsonString() {
                return .init(text: text, filename: "")
            } else {
                return .init(text: selection.header, filename: "")
            }
        }
        return nil
    }

    init(viewModel: SectionedListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }

            if let websocketListItems = viewModel.websocketListItems {
                List(selection: $selection, content: {
                    ForEach(websocketListItems, id: \.self) { viewModel in
                        HStack {
                            Image(systemName: viewModel.imageName)
                            Text(viewModel.date)
                            Text(viewModel.header)
                                .lineLimit(1)
                        }
                    }
                })
            } else {
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
            } else if let textViewerViewModel {
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

    private static func makeWebSocketPreview() -> some View {
        let testJsonString = [
            "param3": 10,
            "param1": "a",
            "param2": true,
            "dict": [
                "param3": 10,
                "param1": "a",
                "param2": true,
            ],
        ].toJsonString()

        ([
            .init(message: .string(testJsonString), type: .sent),
            .init(message: .string("test"), type: .received),
            .init(message: .string(testJsonString), type: .sent),
        ] as [HTTPRequest.WebsocketMessage]).forEach {
            request.apprendWebSockedMessage($0)
        }
        let descriptor = WebSocketTabDescriptor(request: request)
        let viewModel = SectionedListViewModel(descriptor: descriptor)
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

            NavigationStack {
                makeWebSocketPreview()
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Web Socket")
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
