import Foundation

class SwizzlingRequestInterceptor: RequestInterceptor {
    var delegate: (any RequestInterceptorDelegate)?
    private var requests: [URLSessionTask: Data] = [:]

    func activate() {
        NetworkingSwizzler.shared.delegate = self
        try? NetworkingSwizzler.shared.activate()
    }

    func deactivate() {

    }
}

private enum SwizzlingRequestInterceptorError: Error {
    case unexpectedResponse
}

extension SwizzlingRequestInterceptor: NetworkingSwizzlerDelegate {

    
    func taskDidResume(_ task: URLSessionTask) {
        guard let urlRequest = task.originalRequest else { return }
        delegate?.willFireRequest(urlRequest: urlRequest, hash: urlRequest.hashValue)
    }

    func task(_ task: URLSessionTask, didReceiveResponse response: HTTPURLResponse) {
        guard let urlRequest = task.originalRequest else { return }

    }

    func task(_ task: URLSessionTask, didReceiveData data: Data) {
        if var existingData = requests[task] {
            existingData.append(data)
        } else {
            requests[task] = data
        }
    }

    func task(_ task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let urlRequest = task.originalRequest else { return }
        let response = task.response as? HTTPURLResponse

        if let error {
            delegate?.didComplete(request: urlRequest, response: .failure(response: response, error: error), hash: urlRequest.hashValue)
            return
        }
        guard let response else {
            delegate?.didComplete(
                request: urlRequest,
                response: .failure(response: response, error: SwizzlingRequestInterceptorError.unexpectedResponse),
                hash: urlRequest.hashValue
            )
            return
        }
        delegate?.didComplete(request: urlRequest, response: .success(response: response, data: requests[task]), hash: urlRequest.hashValue)
    }

    func webSocketTask(_ task: URLSessionTask, didSendMessage message: URLSessionWebSocketTask.Message) {
        delegate?.webSocketDidSendMessage(task: task, message: message)
    }

    func webSocketTask(_ task: URLSessionTask, didReceiveMessage message: URLSessionWebSocketTask.Message) {
        delegate?.webSocketDidReceive(task: task, message: message)
    }
}
