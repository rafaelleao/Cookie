import SwiftUI
import Core
import Combine

struct RequestDetailTabSummary: View {
    @ObservedObject var viewModel: RequestDetailTabViewModel
    
    var body: some View {
        VStack {
            SearchBar(text: $viewModel.searchText, placeholder: "Search")
            List {
                ForEach(viewModel.data, id: \.self) { row in
                    Section(header: Text(row.title)) {
                        ForEach(row.pairs, id: \.key) { pair in
                            RequestDetailItem(pair: pair)
                        }
                    }
                }
            }
        }.tabItem {
            Text("Summary")
        }
        .listStyle(GroupedListStyle())
    }
}

struct RequestDetailTabSummary_Previews: PreviewProvider {
    
    static var previews: some View {
        let x = SummaryTabDescriptor(request: TestRequest.testRequest)
        let viewModel = RequestDetailTabViewModel(sections: x.sections())
        return RequestDetailTabSummary(viewModel: viewModel)
    }
}

protocol TabDescriptor {
    init(request: HTTPRequest)
    func sections() -> [SectionData]
}

struct SummaryTabDescriptor: TabDescriptor {
    let request: HTTPRequest
    
    func sections() -> [SectionData] {
        [SectionData(title: "", pairs: summary())]
    }

    private func summary() -> [KeyValuePair] {
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

class RequestDetailTabViewModel: ObservableObject {
    private let sections: [SectionData]
    @Published var data: [SectionData] = []
    @Published var searchText: String = ""
    private var bindings: [AnyCancellable] = []
    
    init(sections: [SectionData]) {
        self.sections = sections
        $searchText.sink { [unowned self] text in
            print(text)
            self.filter(searchString: text)
        }.store(in: &bindings)
    }

    private func filter(searchString: String) {
        if searchString.isEmpty {
            data = sections
            return
        }
        var results: [SectionData] = []
        for section in sections {
            var pairs: [KeyValuePair] = []
            for pair in section.pairs {
                if pair.key.lowercased().range(of: searchString) != nil ||
                    pair.value?.lowercased().range(of: searchString) != nil {
                    pairs.append(pair)
                }
            }
            let section = SectionData(title: section.title, pairs: pairs)
            results.append(section)
        }
        self.data = results
    }
}
