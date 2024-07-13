import Combine
import Networking
import SwiftUI

@available(iOS 16.0, *)
@available(macOS 10.15, *)
struct WebsocketListItemViewModel: Hashable {
    static func == (lhs: WebsocketListItemViewModel, rhs: WebsocketListItemViewModel) -> Bool {
        lhs.message.id == rhs.message.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(message.id)
    }

    let message: HTTPRequest.WebsocketMessage

    var imageName: String {
        message.type == .sent ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
    }

    var header: String {
        if case let .string(value) = message.message {
            return value
        } else {
            return "undefined"
        }
    }

    var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        let date = dateFormatter.string(from: message.date)
        return date
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
class WebSocketViewModel: ObservableObject {//
     //@Published
    var websocketListItems: [WebsocketListItemViewModel]
    let request: HTTPRequest
    var selection: WebsocketListItemViewModel?

    init(request: HTTPRequest) {
        self.request = request
        self.websocketListItems = request.webSockedMessages.map { WebsocketListItemViewModel(message: $0) }
    }

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
}

@available(iOS 16.0, *)
@available(macOS 13, *)
struct WebSocketTab: View, Identifiable {
    @ObservedObject var viewModel: WebSocketViewModel
    private(set) var id = UUID()

    init(viewModel: WebSocketViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            List(selection: $viewModel.selection, content: {
                ForEach(viewModel.websocketListItems, id: \.self) { viewModel in
                    HStack {
                        Image(systemName: viewModel.imageName)
                        Text(viewModel.date)
                        Text(viewModel.header)
                            .lineLimit(1)
                    }
                }
            })

            #if os(iOS)
//            if let action = viewModel.action {
//                NavigationLink(destination:
//                    TextViewer(viewModel: action.handler())
//                ) {
//                    Text(action.title)
//                        .bold()
//                }
//                .padding()
//                .searchable(text: $viewModel.searchText, prompt: "Search")
//            }
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
struct WebSocketTab_Previews: PreviewProvider {
    static let request = TestRequest.completedTestRequest

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
        let viewModel = WebSocketViewModel(request: request)
        return WebSocketTab(viewModel: viewModel)
    }

    static var previews: some View {
        Group {
            NavigationStack {
                makeWebSocketPreview()
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Web Socket")
        }
    }
}
