//
//  RequestDetailItem.swift
//  Cookie
//
//  Created by Rafael Leão on 10.09.21.
//

import SwiftUI

struct RequestDetailRow: View {
    @ObservedObject var viewModel: RequestDetailRowViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            if #available(iOS 15, *) {
                Text(viewModel.attributedTitle)
                    .font(.system(.headline, design: .monospaced))
                    .textSelection(.enabled)
                Text(viewModel.attributedSubtitle)
                    .font(.system(.subheadline, design: .monospaced))
                    .textSelection(.enabled)
            } else {
                Text(viewModel.title)
                    .font(.system(.headline, design: .monospaced))
                Text(viewModel.subtitle)
                    .font(.system(.subheadline, design: .monospaced))
            }
        })
    }
}

struct RequestDetailRow_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetailRow(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
            .padding()
    }

    static var viewModel = RequestDetailRowViewModel(pair: KeyValuePair("foo-bar-baz", "baz-bar-foo"), searchText: "ba")
}
