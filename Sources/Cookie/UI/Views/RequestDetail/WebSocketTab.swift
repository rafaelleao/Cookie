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
class WebSocketViewModel: ObservableObject { //
    //@Published
    var websocketListItems: [WebsocketListItemViewModel]
    let request: HTTPRequest
    var selection: WebsocketListItemViewModel? {
        didSet {
            showSheet = true
        }
    }

    @Published var searchText: String = ""
    @Published var showSheet: Bool = false

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
    @State private var showingSheet = false

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
                            .font(.footnote)
                        Text(viewModel.header)
                            .font(.system(.subheadline, design: .monospaced))
                            .lineLimit(1)
                    }
                }
            })

            #if os(macOS)
            if let textViewerViewModel = viewModel.textViewerViewModel {
                TextViewer(viewModel: textViewerViewModel)
            }
            #endif
        }.modify {
            #if os(iOS)
            $0.sheet(isPresented: $viewModel.showSheet) {
                TextViewer(viewModel: viewModel.textViewerViewModel ?? TextViewerViewModel(text: "", filename: ""))
                    .presentationDetents([.fraction(0.25), .medium, .large])
                    .apply {
                        if #available(iOS 16.4, *) {
                            $0.presentationBackgroundInteraction(.enabled(upThrough: .medium))
                        }
                    }
            }
            #endif
        }
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
struct WebSocketTab_Previews: PreviewProvider {
    private static func makeWebSocketPreview() -> some View {
        let request = TestRequest.webSocket
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
