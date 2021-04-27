import SwiftUI
import Core

extension HTTPRequest: Identifiable {

}

struct RequestList: View {
    @ObservedObject var viewModel: RequestListViewModel

    var list: some View {
        List(viewModel.source) { request in
            NavigationLink(destination: RequestDetail(viewModel: RequestDetailViewModel(request: request))) {
                RequestRow(viewModel: RequestViewModel(request: request))
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                #if os(iOS)
                    list
                        .listStyle(GroupedListStyle())
                        .navigationBarTitle("Requests", displayMode: .inline)
                        if viewModel.connectedClient != nil {
                            Text("Connected to \(viewModel.connectedClient!)")
                        }
                #else
                    list
                #endif

            }

        }
    }
}

struct Requests_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = RequestListViewModel()
        viewModel.source = [TestRequest.testRequest, TestRequest.completedTestRequest]
        #if os(iOS)
        viewModel.connectedClient = "MacOS"
        #endif
        return RequestList(viewModel: viewModel)
    }
}

struct TestRequest {
    static var testRequest: HTTPRequest {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todosaiejfoisjefiajo?qwertyuiop=asdfghjkl&zxcvbnm=zxcvbnm")!
        let request = URLRequest(url: url)
        let httpOperation = HTTPRequest(request: request)
        return httpOperation
    }

    static var completedTestRequest: HTTPRequest {
        let url = URL(string: "www.test.com/path?foo=bar&c&a=b")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["header": "test"]
        let httpOperation = HTTPRequest(request: request)
        let response = ["a": "b"]
        let jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)

        let httpResponse = HTTPURLResponse(url: url, statusCode: 201, httpVersion: nil, headerFields: ["header": "value"])
        httpOperation.response = HTTPResponse.success(response: httpResponse!, data: jsonData)
        return httpOperation
    }
}
