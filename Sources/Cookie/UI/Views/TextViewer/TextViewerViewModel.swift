import Foundation
import SwiftUI

private struct FontSize {
    static let minimum = 8
    static let initial = 14
    static let maximum = 20
}

class TextViewerViewModel: ObservableObject {
    let text: String
    let filename: String
    let minimumFontSize = FontSize.minimum
    let maximumFontSize = FontSize.maximum
    var searchText: String = "" {
        didSet {
            updateAttributedText()
        }
    }
    @Published var currentFontSize = FontSize.initial
    @available(iOS 15, *)
    var attributedText: AttributedString {
        let attributedTitle = NSAttributedString(string: text).highlight(searchText, highlightedTextColor: .orange)
        return AttributedString(attributedTitle)
    }

    private func updateAttributedText() {
        if #available(iOS 15, *) {
            self.objectWillChange.send()
        }
    }
    
    var font: Font {
        let font = Font.system(size: CGFloat(currentFontSize))
        if #available(iOS 15.0, *) {
            return font.monospaced()
        } else {
            return font
        }
    }

    init(text: String, filename: String) {
        self.text = text
        self.filename = filename
    }
    
    func share() {
        let activityItems = [text]
        let av = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        UIViewController.top?.present(av, animated: true, completion: nil)
    }
}
