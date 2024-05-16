import Foundation

@available(iOS 16.0, *)
@available(macOS 13, *)
class WebSocketTabDescriptor: TabDescriptor {
    let request: HTTPRequest

    required init(request: HTTPRequest) {
        self.request = request
    }

    var title: String {
        "WebSocket"
    }

    var image: String {
        "icloud.and.arrow.up"
    }

    func sections() -> [SectionData] {
        let pairs = request.webSockedMessages.compactMap {
            if case let .string(value) = $0.message {
                return KeyValuePair(value, nil)
            }
            return nil
        }
        return [
            SectionData(title: "Web Socket", pairs: pairs),
        ]
    }

    func action() -> Action? {
        nil
    }

    var textViewerViewModel: TextViewerViewModel? {
        nil
    }
}
