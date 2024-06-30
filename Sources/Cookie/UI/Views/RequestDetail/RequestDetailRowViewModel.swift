import Combine
import Foundation
import Networking

@available(iOS 16.0, *)
@available(macOS 13, *)
class RequestDetailRowViewModel: ObservableObject {
    let pair: Networking.KeyValuePair
    let searchText: String

    init(pair: KeyValuePair, searchText: String) {
        self.pair = pair
        self.searchText = searchText
    }

    var title: AttributedString {
        AttributedString(pair.key, highlightedString: searchText)
    }

    var subtitle: AttributedString {
        AttributedString(pair.value ?? "", highlightedString: searchText)
    }
}
