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
    @Published var currentFontSize = FontSize.initial

    var font: Font {
        Font.system(size: CGFloat(currentFontSize))
    }

    init(text: String, filename: String) {
        self.text = text
        self.filename = filename
    }
}
