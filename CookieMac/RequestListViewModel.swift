import Foundation

class RequestListViewModel: ObservableObject {

    @Published var source: [HTTPRequest] = []

    init() {
        source.append(TestRequest.testRequest)
        source.append(TestRequest.completedTestRequest)
    }

    func clearRequest() {
    }
}