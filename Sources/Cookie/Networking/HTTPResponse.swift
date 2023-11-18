import Foundation

enum HTTPResponse {
    case success(response: HTTPURLResponse, data: Data?)
    case failure(response: HTTPURLResponse?, error: Error?)

    var urlResponse: HTTPURLResponse? {
        switch self {
        case let .success(response, _):
            return response
        case let .failure(response, _):
            return response
        }
    }

    var responseData: Data? {
        guard case let .success(_, data) = self else {
            return nil
        }

        return data
    }

    var responseString: String? {
        guard let responseData else {
            return nil
        }
        if let jsonString = responseData.toJsonString() {
            return jsonString
        }

        return responseData.toString(encoding: .utf8)
    }
}
