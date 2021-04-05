import SwiftUI

struct RequestDetailTabResponse: View {
    @ObservedObject var viewModel: RequestDetailTabResponseViewModel
    @State private var showingSheet = false

    #if os(iOS)
    var body: some View {
        VStack {
            if viewModel.canShowResponse() {
                NavigationLink(destination: TextViewer(viewModel: viewModel.textViewerViewModel()!)) {
                    Text("View Response")
                        .padding()
                }
            }
            List {
                ForEach(viewModel.data, id: \.self) { row in
                    //if row.pairs.count > 0 {
                        Section(header: Text(row.title)) {
                            ForEach(row.pairs, id: \.key) { pair in
                                RequestDetailItem(pair: pair)
                            }
                        }
                    //}
                }
            }
        }.tabItem {
            Text("Response")
        }
        .listStyle(GroupedListStyle())
    }
    #else
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.data, id: \.self) { row in
                    //if row.pairs.count > 0 {
                        Section(header: Text(row.title)) {
                            ForEach(row.pairs, id: \.key) { pair in
                                RequestDetailItem(pair: pair)
                            }
                        }
                    //}
                }
            }
            if viewModel.canShowResponse() {
                TextViewer(viewModel: viewModel.textViewerViewModel()!)
            }
        }.tabItem {
            Text("Response")
        }
    }
    #endif
}

struct RequestDetailTabResponse_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetailTabResponse(viewModel: RequestDetailTabResponseViewModel(request: TestRequest.completedTestRequest))
    }
}

class RequestDetailTabResponseViewModel: ObservableObject {
    let request: HTTPRequest

    @Published var data: [SectionData] = []

    init(request: HTTPRequest) {
        self.request = request
        data = [
            SectionData(title: "Response Headers", pairs: headers())
        ]
    }

    private func headers() -> [KeyValuePair] {
        var headers: [KeyValuePair] = []
        if let allHeaders = request.response?.urlResponse?.allHeaderFields {
            for (key, value) in allHeaders {
                headers.append(KeyValuePair(key.description, value as? String))
            }
        }

        return headers.sorted()
    }

    func canShowResponse() -> Bool {
        return responseString()?.isEmpty != nil
    }

    func textViewerViewModel() -> TextViewerViewModel? {
        guard let response = responseString() else {
            return nil
        }
        let viewModel = TextViewerViewModel(text: response, filename: suggestedFilename() ?? "")
        return viewModel
    }

    private func suggestedFilename() -> String? {
        guard case .success(let response, _)? = request.response else {
            return nil
        }
        return response.suggestedFilename
    }

    private func responseString() -> String? {
        request.response?.responseString
    }
}
