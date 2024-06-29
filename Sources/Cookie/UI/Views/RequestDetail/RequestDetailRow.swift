import SwiftUI
import Networking

@available(iOS 16.0, *)
@available(macOS 13, *)
struct RequestDetailRow: View {
    @ObservedObject var viewModel: RequestDetailRowViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            Text(viewModel.title)
                .font(.system(.headline, design: .monospaced))
                .textSelection(.enabled)
            Text(viewModel.subtitle)
                .font(.system(.subheadline, design: .monospaced))
                .textSelection(.enabled)
        })
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
struct RequestDetailRow_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetailRow(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
            .padding()
    }

    static var viewModel = RequestDetailRowViewModel(pair: KeyValuePair("foo-bar-baz", "baz-bar-foo"), searchText: "ba")
}
