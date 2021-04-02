import SwiftUI

struct RequestRow: View {
    @State var viewModel: RequestViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            Text(viewModel.value).font(.system(.subheadline))
            HStack {
                Text(viewModel.key).font(.system(.caption))
                Text(viewModel.method ?? "").font(.system(.caption)).bold()
                if viewModel.statusCode != nil {
                    Text("\(viewModel.statusCode!)").font(.system(.caption)).bold()
                }
            }
        })
    }
}


struct RequestRow_Previews: PreviewProvider {
    static var previews: some View {
        RequestRow(viewModel: RequestViewModel(request: TestRequest.testRequest))
    }
}
