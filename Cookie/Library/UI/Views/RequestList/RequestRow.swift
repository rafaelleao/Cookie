import SwiftUI

struct RequestRow: View {
    @ObservedObject var viewModel: RequestViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            Text(viewModel.value).font(.system(.subheadline))
            HStack {
                Text(viewModel.key)
                    .font(.system(.caption))

                Text(viewModel.method ?? "")
                    .foregroundColor(.black)
                    .bold()
                    .modifier(RoundedLabel(backgroundColor: .white))
                
                if viewModel.statusCode != nil {
                    Text("\(viewModel.statusCode!)")
                        .bold()
                        .foregroundColor(.white)
                        .modifier(RoundedLabel(backgroundColor: .green))
                } else {
                    if viewModel.error != nil {
                        Text("Error")
                            .bold()
                            .modifier(RoundedLabel(backgroundColor: .red))
                    }
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
        }
    }

    static var previews: some View {
        Group {
            makePreview()
                .preferredColorScheme(.light)
            makePreview()
                .preferredColorScheme(.dark)
        }
    }
}
