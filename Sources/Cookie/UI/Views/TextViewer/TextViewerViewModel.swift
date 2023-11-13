import Foundation
import SwiftUI

private enum FontSize {
    static let minimum = 8
    static let initial = 14
    static let maximum = 20
}

@available(macOS 13, *)
class TextViewerViewModel: ObservableObject {
    let charLimit = 15000
    let text: String
    let originalText: String
    let filename: String
    let minimumFontSize = FontSize.minimum
    let maximumFontSize = FontSize.maximum
    var searchText: String = "" {
        didSet {
            updateAttributedText()
        }
    }

    private(set) var isClipped = false

    @Published var currentFontSize = FontSize.initial

    var attributedText: AttributedString {
        let attributedTitle = NSAttributedString(string: text) // .highlight(searchText, highlightedTextColor: .orange)
        return AttributedString(string: text, highlightedString: searchText)
    }

    private func updateAttributedText() {
        self.objectWillChange.send()
    }

    var font: Font {
        .system(size: CGFloat(currentFontSize))
    }

    init(text: String, filename: String) {
        if text.count > charLimit {
            self.text = String(text.prefix(charLimit))
            self.isClipped = true
        } else {
            self.text = text
            self.isClipped = false
        }
        self.originalText = text
        self.filename = filename
    }

    func share() {
//        let activityItems = [originalText]
//        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            activityViewController.popoverPresentationController?.sourceView = UIViewController.top?.presentingViewController?.view
//        }
//
//        UIViewController.top?.present(activityViewController, animated: true, completion: nil)
    }
}
