import Foundation

@available(iOS 16.0, *)
@available(macOS 13.0, *)
protocol RequestRepositoryDelegate: AnyObject {
    func requestRepository(_ requestRepository: RequestRepository, didAddRequest httpRequest: HTTPRequest)
}

@available(iOS 16.0, *)
@available(macOS 13.0, *)
protocol RequestRepository: Actor {
    var requests: [HTTPRequest] { get }
    func setDelegate(_ delegate: RequestRepositoryDelegate)
    func clearRequests()
}

@available(iOS 16.0, *)
@available(macOS 13.0, *)
actor RequestRepositoryImpl: RequestRepository {
    private(set) var requests = [HTTPRequest]()
    private var openRequests = [Int: HTTPRequest]()
    private weak var delegate: RequestRepositoryDelegate?

    func clearRequests() {
        requests.removeAll()
    }

    func setDelegate(_ delegate: RequestRepositoryDelegate) {
        self.delegate = delegate
    }

    func addRequest(urlRequest: URLRequest, hash: Int) {
        let request = HTTPRequest(request: urlRequest)
        requests.insert(request, at: 0)
        assert(openRequests[hash] == nil)
        openRequests[hash] = request
        delegate?.requestRepository(self, didAddRequest: request)
    }

    func setResponse(urlRequest: URLRequest, response: HTTPResponse?, hash: Int) {
        guard let httpRequest = openRequests[hash] else {
            return
        }
        httpRequest.responseDate = Date()
        httpRequest.response = response
        openRequests[hash] = nil
    }

    func messageSent(task: URLSessionTask, message: URLSessionWebSocketTask.Message) {
        guard let request = requests.first(where: { task.originalRequest == $0.urlRequest }) else {
            return
        }
        request.webSockedMessages.append(.init(message: message, taskIdentifier: task.taskIdentifier))
    }

    func messageReceived(task: URLSessionTask, message: URLSessionWebSocketTask.Message) {
        guard let request = requests.first(where: { task.originalRequest == $0.urlRequest }) else {
            return
        }
        request.webSockedMessages.append(.init(message: message, taskIdentifier: task.taskIdentifier))
    }
}
