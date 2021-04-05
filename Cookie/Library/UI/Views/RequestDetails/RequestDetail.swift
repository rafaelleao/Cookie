import SwiftUI

struct SectionData {
    let id = UUID()
    let title: String
    let pairs: [KeyValuePair]
}

extension SectionData: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

struct RequestDetailItem: View {
    @State var pair: KeyValuePair

    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            Text(pair.key).font(.system(.headline, design: .monospaced))
            Text(pair.value ?? "").font(.system(.subheadline, design: .monospaced))
        })
    }
}

struct RequestDetail: View {
    @ObservedObject var viewModel: RequestDetailViewModel

    var body: some View {
        let tabview = TabView {
            RequestDetailTabSummary(viewModel: viewModel.summaryViewModel())
            RequestDetailTabRequest(viewModel: viewModel.requestTabViewModel())
            RequestDetailTabResponse(viewModel: viewModel.responseTabViewModel())
        }
        #if os(iOS)
            return tabview
                .navigationBarTitle(viewModel.title)
        #else
            return tabview
        #endif
    }
}

struct RequestDetails_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetail(viewModel: RequestDetailViewModel(request: TestRequest.completedTestRequest))
    }
}

class RequestDetailViewModel: ObservableObject {
    let request: HTTPRequest

    init(request: HTTPRequest) {
        self.request = request
    }

    var title: String {
        request.urlRequest.url?.host ?? "Request Details"
    }

    func summaryViewModel() -> RequestDetailTabSummaryViewModel {
        RequestDetailTabSummaryViewModel(request: request)
    }

    func requestTabViewModel() -> RequestDetailTabRequestViewModel {
        RequestDetailTabRequestViewModel(request: request)
    }

    func responseTabViewModel() -> RequestDetailTabResponseViewModel {
        RequestDetailTabResponseViewModel(request: request)
    }
}
