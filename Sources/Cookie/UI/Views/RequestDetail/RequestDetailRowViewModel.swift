import Combine
import Foundation

@available(macOS 13, *)
class RequestDetailRowViewModel: ObservableObject {
    let pair: KeyValuePair
    let searchText: String

    init(pair: KeyValuePair, searchText: String) {
        self.pair = pair
        self.searchText = searchText
    }

    private var title: String {
        pair.key
    }

    private var subtitle: String {
        pair.value ?? ""
    }

    var attributedTitle: AttributedString {
        AttributedString(title, highlightedString: searchText)
    }

    var attributedSubtitle: AttributedString {
        AttributedString(subtitle, highlightedString: searchText)
    }
}
