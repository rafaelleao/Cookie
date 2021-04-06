import Foundation
import UIKit.UIDevice
import Core

class RequestListViewModel: ObservableObject {
    
    @Published var source: [HTTPRequest] = []
    private let dataTransferService: DataTransferService

    init() {
        source = Cookie.shared.requests
        dataTransferService = DataTransferService(deviceName: UIDevice.current.name)
        dataTransferService.delegate = self
        Cookie.shared.internalDelegate = self
    }

    func clearRequest() {
        Cookie.shared.clearRequests()
        reloadRequests()
    }

    private func reloadRequests() {
        source = Cookie.shared.requests
    }
}

extension RequestListViewModel: RequestDelegate {

    func shouldFireURLRequest(_ urlRequest: URLRequest) -> Bool {
        return true
    }
    
    func willFireRequest(_ httpRequest: HTTPRequest) {
        reloadRequests()
    }
    
    func didCompleteRequest(_ httpRequest: HTTPRequest) {
        reloadRequests()
    }
}

extension RequestListViewModel: DataTransferServiceDelegate {
    func connectedDevicesChanged(service: DataTransferService, connectedDevices: [String]) {
        print(connectedDevices)
        if let master = connectedDevices.first {
            if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: source, requiringSecureCoding: false) {
                dataTransferService.sendData(encodedData)
            }
        }
    }

    func didReceiveData(service: DataTransferService, data: Data) {
        print(data)
    }
}
