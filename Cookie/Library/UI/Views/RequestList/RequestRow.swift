import SwiftUI

struct RequestRow: View {
    @ObservedObject var viewModel: RequestViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            Text(viewModel.value).font(.system(.subheadline))
            HStack {
                if viewModel.isLoading {
                    LoadingIndicator()
                }

                Text(viewModel.key)
                    .font(.system(.caption))

                Text(viewModel.method ?? "")
                    .foregroundColor(.black)
                    .bold()
                    .modifier(RoundedLabel(backgroundColor: .white))
                
                if let (code, color) = viewModel.result {
                    Text(code)
                        .bold()
                        //.foregroundColor(.white)
                        .modifier(RoundedLabel(backgroundColor: color))
                }
            }
        })
        .padding(5)
    }
}

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

struct RequestRow_Previews: PreviewProvider {
    static private func makePreview() -> some View {
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
