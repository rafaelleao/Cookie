import Foundation

enum RequestStatus {
    case loading
    case completed(statusCode: Int)
    case error
}
/*
protocol SearchableListItem {
    var key: String {get}
    var value: String {get}
    var method: String? {get}
    var statusCode: Int? {get}
    var customLabel: String? {get}
    var requestStatus: RequestStatus? {get}
}
*/
