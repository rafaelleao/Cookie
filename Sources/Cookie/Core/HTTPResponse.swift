import Foundation

public enum HTTPResponse {
    case success(response: HTTPURLResponse, data: Data?)
    case failure(response: HTTPURLResponse?, error: Error?)

    public var urlResponse: HTTPURLResponse? {
        switch self {
        case let .success(response, _):
            return response
        case let .failure(response, _):
            return response
        }
    }

    public var responseData: Data? {
        guard case let .success(_, data) = self else {
            return nil
        }

        return data
    }

    public var responseString: String? {
        guard let responseData = responseData else {
            return nil
        }
        if let jsonString = responseData.toJsonString() {
            return jsonString
        }

        return responseData.toString(encoding: .utf8)
    }
}
