import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()

    var body: some View {
        VStack(alignment: .center, spacing: 30, content: {
            Button("Show") {
                viewModel.show()
            }

            Button("Send Requests") {
                viewModel.sendTestRequests()
            }
            Toggle("Enabled", isOn: $viewModel.enabled)

        })
        .padding()
        .onAppear(perform: {
            viewModel.sendTestRequests()
            viewModel.show()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
