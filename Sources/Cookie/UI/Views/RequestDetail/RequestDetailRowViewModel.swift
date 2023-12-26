import Combine
import Foundation

@available(iOS 16.0, *)
@available(macOS 13, *)
class RequestDetailRowViewModel: ObservableObject {
    let pair: KeyValuePair
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
