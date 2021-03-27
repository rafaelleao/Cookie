//
//  RequestDetailRowViewModel.swift
//  Cookie
//
//  Created by Rafael Leão on 19.09.21.
//

import Combine
import Foundation

class RequestDetailRowViewModel: ObservableObject {
    let pair: KeyValuePair
    let searchText: String

    init(pair: KeyValuePair, searchText: String) {
        self.pair = pair
        self.searchText = searchText
    }

    var title: String {
        pair.key
    }
    
    var subtitle: String {
        pair.value ?? ""
    }
    
    @available(iOS 15, *)
    var attributedTitle: AttributedString {
        let attributedTitle = NSAttributedString(string: title).highlight(searchText, highlightedTextColor: .orange)
        return AttributedString(attributedTitle)
    }

    @available(iOS 15, *)
    var attributedSubtitle: AttributedString {
        let attributedTitle = NSAttributedString(string: subtitle).highlight(searchText, highlightedTextColor: .orange)
        return AttributedString(attributedTitle)
    }
}
