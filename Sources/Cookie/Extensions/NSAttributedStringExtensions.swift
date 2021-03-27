//
//  NSAttributedStringExtensions.swift
//
//
//  Created by Rafael Leão on 18.09.21.
//

import UIKit

extension NSAttributedString {
    func highlight(_ text: String, highlightedTextColor: UIColor) -> NSAttributedString {
        guard let ranges = ranges(of: text) else {
            return self
        }
        let highlightedText = emphasizeText(in: ranges)
        return highlightedText
    }

    private func ranges(of searchString: String) -> [NSRange]? {
        let str = string.lowercased()
        return str.ranges(of: searchString.lowercased())
    }

    private func emphasizeText(in ranges: [NSRange]) -> NSAttributedString {
        var attrs: [NSAttributedString.Key: Any] = [.backgroundColor: UIColor.orange]
        attrs[.foregroundColor] = UIColor.white

        let attributedText = NSMutableAttributedString(attributedString: self)
        for range in ranges {
            attributedText.addAttributes(attrs, range: range)
        }
        return attributedText
    }
}
