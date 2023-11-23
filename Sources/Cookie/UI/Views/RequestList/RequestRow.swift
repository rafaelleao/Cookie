import SwiftUI

@available(iOS 16.0, *)
@available(macOS 13, *)
struct RequestRow: View {
    @ObservedObject var viewModel: RequestViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2, content: {
            Text(viewModel.attributedValue)
                .font(.system(.caption, design: .monospaced))
            HStack {
                Text(viewModel.key)
                    .font(.system(.caption))
                    .italic()

                Text(viewModel.method ?? "")
                    .foregroundColor(.black)
                    .bold()
                    .modifier(RoundedLabel(backgroundColor: .white))

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                        .padding(.trailing, 3)
                } else {
                    if let (code, color) = viewModel.result {
                        Text(code)
                            .bold()
                            .foregroundColor(.white)
                            .modifier(RoundedLabel(backgroundColor: color))
                    }
                    if let contentType = viewModel.contentType {
                        Text(contentType)
                            .foregroundColor(.white)
                            .bold()
                            .modifier(RoundedLabel(backgroundColor: .gray))
                    }
                }
            }
        })
        .padding(2)
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
struct RoundedLabel: ViewModifier {
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .font(.caption)
            .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
            .background(backgroundColor)
            .cornerRadius(8.0)
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
struct RequestRow_Previews: PreviewProvider {
    private static func makePreview() -> some View {
        VStack {
            RequestRow(viewModel: RequestViewModel(request: TestRequest.completedTestRequest))
            RequestRow(viewModel: RequestViewModel(request: TestRequest.testRequest))
            RequestRow(viewModel: RequestViewModel(request: TestRequest.serverErrorRequest))
            RequestRow(viewModel: RequestViewModel(request: TestRequest.failedRequest))
        }
    }

    static var previews: some View {
        Group {
            makePreview()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.light)
            makePreview()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
