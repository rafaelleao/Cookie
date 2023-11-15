import SwiftUI

@available(macOS 13.0, *)
extension AttributedString {
    init(
        _ string: String,
        highlightedString: String,
        attributeContainer: AttributeContainer = AttributeContainer().backgroundColor(.orange)
    ) {
        guard !string.isEmpty, !highlightedString.isEmpty else {
            self.init(stringLiteral: string)
            return
        }

        let occurrences = string.lowercased().ranges(of: highlightedString.lowercased())
        guard !occurrences.isEmpty else {
            self.init(stringLiteral: string)
            return
        }

        self = AttributedString()
        var previousHighlightEnd = string.startIndex
        for occurrence in occurrences {
            let unhighlightedChunk = string[previousHighlightEnd ..< occurrence.lowerBound]
            self += AttributedString(unhighlightedChunk)
            let highlightedChunk = string[occurrence]
            self += AttributedString(highlightedChunk, attributes: attributeContainer)
            previousHighlightEnd = occurrence.upperBound
        }
        if let lastOccurrence = occurrences.last {
            let unhighlightedChunk = string[lastOccurrence.upperBound ..< string.endIndex]
            let unhighlighted = AttributedString(unhighlightedChunk)
            self += unhighlighted
        }
    }
}
