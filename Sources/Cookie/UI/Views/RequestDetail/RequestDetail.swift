import SwiftUI

struct RequestDetail: View {
    @ObservedObject var viewModel: RequestDetailViewModel
    @State var detailPresented = false
    var onDismiss: (() -> Void)?

    var body: some View {
        let tabs = viewModel.tabDescriptors().map {
            RequestDetailTab(viewModel: RequestDetailTabViewModel(descriptor: $0), detailPresented: $detailPresented)
        }

        let tabview = TabView {
            ForEach(tabs) { $0 }
        }
            .onAppear {
                if #available(iOS 15.0, *) {
                    let appearance = UITabBarAppearance()
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }
            .onDisappear(perform: {
                if !detailPresented {
                    onDismiss?()
                }
            })
            .navigationBarTitle(viewModel.title)

        return tabview
    }
}

extension RequestDetail: Equatable {
    static func == (lhs: RequestDetail, rhs: RequestDetail) -> Bool {
        lhs.viewModel.request == rhs.viewModel.request
    }
}

struct RequestDetail_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetail(viewModel: RequestDetailViewModel(request: TestRequest.completedTestRequest), onDismiss: nil)
    }
}
