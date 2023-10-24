import SwiftUI

@available(macOS 13, *)
struct RequestDetail: View {
    @ObservedObject var viewModel: RequestDetailViewModel

    var body: some View {
        VStack {
            Picker("", selection: $viewModel.segmentationSelection) {
                ForEach(viewModel.tabDescriptors, id: \.title) { vm in
                    Text(vm.title)
                }
            }
            .padding()
            .pickerStyle(.segmented)

            let vm = viewModel.childViewModel
            RequestDetailTab(viewModel: vm)
//                .searchable(text: $viewModel.searchText, prompt: "Search")
        }
    }
}

//@available(macOS 13, *)
//extension RequestDetail: Equatable {
//    static func == (lhs: RequestDetail, rhs: RequestDetail) -> Bool {
//        lhs.viewModel.request == rhs.viewModel.request
//    }
//}

@available(macOS 13, *)
struct RequestDetail_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetail(viewModel: RequestDetailViewModel(request: TestRequest.completedTestRequest))
    }
}
