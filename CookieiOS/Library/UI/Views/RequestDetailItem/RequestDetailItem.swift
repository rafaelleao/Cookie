//
//  RequestDetailItem.swift
//  Cookie
//
//  Created by Rafael Leão on 10.09.21.
//

import SwiftUI
import Core

struct RequestDetailItem: View {
    @State var pair: KeyValuePair

    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            Text(pair.key).font(.system(.headline, design: .monospaced))
            Text(pair.value ?? "").font(.system(.subheadline, design: .monospaced))
        })
    }
}

struct RequestDetailItem_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetailItem(pair: KeyValuePair("foo", "bar"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
