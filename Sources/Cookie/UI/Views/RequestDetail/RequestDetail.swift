import SwiftUI

@available(iOS 16.0, *)
@available(macOS 13, *)
struct RequestDetail: View {
    @ObservedObject var viewModel: RequestDetailViewModel

    var body: some View {
        VStack {
            Picker("", selection: $viewModel.segmentationSelection) {
                ForEach(viewModel.tabDescriptors, id: \.title) { descriptor in
                    Text(descriptor.title)
                }
            }
            .padding()
            .pickerStyle(.segmented)

            RequestDetailTab(viewModel: viewModel.childViewModel)
//                .searchable(text: $viewModel.searchText, prompt: "Search")
        }
    }
}

@available(iOS 16.0, *)
@available(macOS 13, *)
struct RequestDetail_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetail(viewModel: RequestDetailViewModel(request: TestRequest.completedTestRequest))
    }
}
