import SwiftUI
import Core

struct RequestDetailTabSummary: View {
    @ObservedObject var viewModel: RequestDetailTabSummaryViewModel

    var body: some View {
        List {
            ForEach(viewModel.data, id: \.self) { row in
                Section(header: Text(row.title)) {
                    ForEach(row.pairs, id: \.key) { pair in
                        RequestDetailItem(pair: pair)
                    }
                }
            }
        }.tabItem {
            Text("Summary")
        }
        //.listStyle(GroupedListStyle())
    }
}

struct RequestDetailTabSummary_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetailTabSummary(viewModel: RequestDetailTabSummaryViewModel(request: TestRequest.testRequest))
    }
}

class RequestDetailTabSummaryViewModel: ObservableObject {
    let request: HTTPRequest

    @Published var data: [SectionData] = []

    init(request: HTTPRequest) {
        self.request = request
        data = [SectionData(title: "", pairs: loadData())]
    }

    func loadData() -> [KeyValuePair] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        let requestDate = dateFormatter.string(from: request.requestDate)

        var requestData: [KeyValuePair] = []
        requestData.append(KeyValuePair("Request date", requestDate))

        if let date = request.responseDate {
            let responseDate = dateFormatter.string(from: date)
            requestData.append(KeyValuePair("Response date", responseDate))
            let interval = String(format: "%.2f ms", date.timeIntervalSince(request.requestDate))
            requestData.append(KeyValuePair("Interval", interval))
        }

        if let method = request.urlRequest.httpMethod {
            requestData.append(KeyValuePair("Method", method))
        }

        requestData.append(KeyValuePair("Timeout", "\(request.urlRequest.timeoutInterval)"))

        if let response = request.response {
            var statusCode: Int?
            if case .success(let response, _) = response {
                statusCode = response.statusCode
            } else if case .failure(let response, let error as NSError) = response {
                statusCode = response?.statusCode
                requestData.append(KeyValuePair("Error", "\(error.domain)(\(error.code)): \(error.localizedDescription)"))
            }
            if let status = statusCode {
                requestData.append(KeyValuePair("Status", "\(status)"))
            }
        }

        if let url = request.urlRequest.url {
            requestData.append(KeyValuePair("URL", url.absoluteString))
        }

        return requestData
    }
}
