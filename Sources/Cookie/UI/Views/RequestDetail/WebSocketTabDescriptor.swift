import Foundation
import Networking

//struct WebsocketListItem: Hashable {
//    enum Kind {
//        case sent
//        case received
//    }
//    let index: Int
//    let kind: Kind
//    let header: String
//    let date: Date
//}

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
class WebSocketTabDescriptor: SectionedListDescriptor {
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
//        let pairs = request.webSockedMessages.compactMap {
//            if case let .string(value) = $0.message {
//                return KeyValuePair(value, nil)
//            }
//            return nil
//        }
//        return [
//            SectionData(title: "Web Socket", pairs: pairs),
//        ]
        []
    }

    func websocketList() -> [WebsocketListItemViewModel]? {
//        var items: [WebsocketListItem] = []
//        for (index, item) in request.webSockedMessages.enumerated() {
//            let header: String
//            if case let .string(value) = item.message {
//                header = value
//            } else {
//                header = "undefined"
//            }
//            items.append(
//                WebsocketListItem(index: index, kind: .received, header: header, date: item.date)
//            )
//        }
//        return items
        request.webSockedMessages.map { WebsocketListItemViewModel(message: $0) }
    }

    func action() -> Action? {
        nil
    }

    var textViewerViewModel: TextViewerViewModel? {
        nil
    }
}
