import Foundation

@available(macOS 13.0, *)
protocol RequestRepositoryDelegate: AnyObject {
    func requestRepository(_ requestRepository: RequestRepository, didAddRequest httpRequest: HTTPRequest)
}

@available(macOS 13.0, *)
actor RequestRepository {
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
}

@available(macOS 13, *)
extension Cookie: RequestInterceptorDelegate {
    func shouldFireRequest(urlRequest: URLRequest) -> Bool {
        true
    }

    func willFireRequest(urlRequest: URLRequest, hash: Int) {
        Task {
            await requestRepository.addRequest(urlRequest: urlRequest, hash: hash)
        }
    }

    func didComplete(request: URLRequest, response: HTTPResponse, hash: Int) {
        Task {
            await requestRepository.setResponse(urlRequest: request, response: response, hash: hash)
        }
    }
}
