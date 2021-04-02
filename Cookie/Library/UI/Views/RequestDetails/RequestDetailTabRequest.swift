import SwiftUI

struct RequestDetailTabRequest: View {
    @ObservedObject var viewModel: RequestDetailTabRequestViewModel

    var body: some View {
        VStack {
            if viewModel.canShowRequestBody() {
                NavigationLink(destination: TextViewer(viewModel: viewModel.textViewerViewModel()!)) {
                    Text("View Request Body")
                        .padding()
                }
                .padding()
            }
            List {
                ForEach(viewModel.data, id: \.self) { row in
                    //if row.pairs.count > 0 {
                        Section(header: Text(row.title)) {
                            ForEach(row.pairs, id: \.key) { pair in
                                RequestDetailItem(pair: pair)
                            }
                        }
                   // }
                }
            }
        }.tabItem {
            Text("Request")
        }//.listStyle(GroupedListStyle())
    }
}

struct RequestDetailTabRequest_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetailTabRequest(viewModel: RequestDetailTabRequestViewModel(request: TestRequest.testRequest))
    }
}

class RequestDetailTabRequestViewModel: ObservableObject {
    let request: HTTPRequest

    @Published var data: [SectionData] = []

    init(request: HTTPRequest) {
        self.request = request
        data = [
            SectionData(title: "Request Headers", pairs: headers()),
            SectionData(title: "Query Parameters", pairs: queryParams())
        ]
    }

    func canShowRequestBody() -> Bool {
        return request.requestBodyString != nil
    }

    func textViewerViewModel() -> TextViewerViewModel? {
        guard let body = request.requestBodyString else {
            return nil
        }
        let viewModel = TextViewerViewModel(text: body, filename: "")
        return viewModel
    }

    private func headers() -> [KeyValuePair] {
        var pairs: [KeyValuePair] = []
        if let allHTTPHeaderFields = request.urlRequest.allHTTPHeaderFields {
            for (key, value) in allHTTPHeaderFields {
                pairs.append(KeyValuePair(key, value))
            }
        }

        return pairs.sorted()
    }

    private func queryParams() -> [KeyValuePair] {
        var pairs: [KeyValuePair] = []

        if let url = request.urlRequest.url,
            let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = urlComponents.queryItems, !queryItems.isEmpty {
            for (param) in queryItems {
                pairs.append(KeyValuePair(param.name, param.value ?? ""))
            }
        }

        return pairs.sorted()
    }
}
