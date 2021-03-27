import SwiftUI

struct RequestDetail: View {
    @ObservedObject var viewModel: RequestDetailViewModel

    var body: some View {
        let tabs = viewModel.tabDescriptors().map {
            RequestDetailTab(viewModel: RequestDetailTabViewModel(descriptor: $0))
        }
                
        let tabview = TabView {
            ForEach(tabs) { $0 }
        }
            .navigationBarTitle(viewModel.title)

        return tabview
    }
}

struct RequestDetail_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetail(viewModel: RequestDetailViewModel(request: TestRequest.completedTestRequest))
    }
}
