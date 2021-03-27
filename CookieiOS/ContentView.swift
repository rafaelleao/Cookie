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

            Toggle("Send periodically", isOn: $viewModel.sendPeriodically)

            Slider(value: $viewModel.interval, in: 0.1...10, step: 0.1)
                .padding()
            Text("Interval (s): \(viewModel.interval, specifier: "%.1f")")
        })
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
