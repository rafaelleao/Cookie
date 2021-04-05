import SwiftUI

extension HTTPRequest: Identifiable {

}

struct RequestList: View {
    @ObservedObject var viewModel: RequestListViewModel

    var body: some View {
        NavigationView {
            List(viewModel.source) { request in
                NavigationLink(destination: RequestDetail(viewModel: RequestDetailViewModel(request: request))) {
                    RequestRow(viewModel: RequestViewModel(request: request))
                }
            }.listStyle(SidebarListStyle())
            //.navigationBarTitle("Requests", displayMode: .inline)
        }
    }
}

struct Requests_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = RequestListViewModel()

        viewModel.source = [TestRequest.testRequest, TestRequest.completedTestRequest]
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
