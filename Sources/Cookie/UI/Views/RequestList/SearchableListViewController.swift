import Foundation

enum RequestStatus {
    case loading
    case completed(statusCode: Int)
    case error
}
