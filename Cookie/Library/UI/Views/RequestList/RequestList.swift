import SwiftUI
import Core

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
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            }
           // .listStyle(GroupedListStyle())
            .navigationBarTitle("Requests", displayMode: .inline)
        }
    }
}

struct Requests_Previews: PreviewProvider {
    static private func makePreview() -> some View {
        let viewModel = RequestListViewModel()

        viewModel.source = [
            TestRequest.testRequest,
            TestRequest.completedTestRequest,
            TestRequest.serverErrorRequest,
            TestRequest.failedRequest
        ]
        return RequestList(viewModel: viewModel)
    }
    
    static var previews: some View {
        Group {
            makePreview()
                .preferredColorScheme(.light)
            makePreview()
                .preferredColorScheme(.dark)
        }
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
    
    static var serverErrorRequest: HTTPRequest {
        let url = URL(string: "https://example.com/404")!
        let request = URLRequest(url: url)
        let httpOperation = HTTPRequest(request: request)
        
        let httpResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: ["header": "value"])
        let error = NSError(domain: "domain", code: 999, userInfo: nil)
        httpOperation.response = HTTPResponse.failure(response: httpResponse, error: error)

        return httpOperation
    }
    
    static var failedRequest: HTTPRequest {
        let url = URL(string: "https://example.com/error")!
        let request = URLRequest(url: url)
        let httpOperation = HTTPRequest(request: request)
        
        let error = NSError(domain: "domain", code: 999, userInfo: nil)
        httpOperation.response = HTTPResponse.failure(response: nil, error: error)

        return httpOperation
    }
}
