import SwiftUI

@available(iOS 16.0, *)
@available(macOS 13, *)
struct RequestDetail: View {
    @ObservedObject var viewModel: RequestDetailViewModel

    var body: some View {
        VStack {
            HStack {
                Picker("", selection: $viewModel.segmentationSelection) {
                    ForEach(viewModel.tabDescriptors) { descriptor in
                        Text(descriptor.name)
                    }
                }
                .padding()
                .pickerStyle(.segmented)

                #if os(macOS)
                SearchBar(placeholder: "Search", text: $viewModel.searchText)
                    .padding()
                #endif
            }

            viewModel.contentView

            #if os(iOS)
                .searchable(text: $viewModel.searchText, prompt: "Search")
                .autocapitalization(.none)
                .navigationTitle(viewModel.title)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
struct RequestDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                RequestDetail(
                    viewModel: .init(request: TestRequest.webSocket)
                )
            }
            .previewDisplayName("WebSocket")

            NavigationStack {
                RequestDetail(
                    viewModel: .init(request: TestRequest.completedTestRequest)
                )
            }
            .previewDisplayName("Completed")

            NavigationStack {
                RequestDetail(
                    viewModel: .init(request: TestRequest.testRequest)
                )
            }
            .previewDisplayName("In progress")
        }
    }
}
