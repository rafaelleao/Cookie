import Foundation
import UIKit.UIDevice
import Core
import Combine

class RequestListViewModel: ObservableObject {
    
    @Published var source: [HTTPRequest] = []
    private var requestsToSend: [HTTPRequest] = []
    @Published var connectedClient: String?
    private let advertiser: Advertiser
    private var bindings = [AnyCancellable]()

    init() {
        source = Cookie.shared.requests
        advertiser = Advertiser(deviceName: UIDevice.current.name)
        advertiser.$connectedPeers.sink(receiveValue: { [weak self] peers in
            if let client = peers.first {
                self?.setupClientBinding(client: client)
            }
        }).store(in: &bindings)
        Cookie.shared.internalDelegate = self
    }

    func setupClientBinding(client: ConnectedPeer) {
        client.$connected.sink(receiveValue: { connected in
            if connected {
                self.sendData(client: client)
            }
        }).store(in: &bindings)
        connectedClient = client.peerId.displayName
    }

    func sendData(client: ConnectedPeer) {
        if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: source, requiringSecureCoding: false) {
            let sent = advertiser.sendData(encodedData, peerId: client.peerId)
            print("data sent \(sent)")
        }
    }

    func clearRequest() {
        Cookie.shared.clearRequests()
        reloadRequests()
    }

    private func reloadRequests() {
        DispatchQueue.main.async {
            self.source = Cookie.shared.requests
        }
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
        requestsToSend.append(httpRequest)
    }
}
/*
extension RequestListViewModel: DataTransferServiceDelegate {
    func connectedDevicesChanged(service: DataTransferService, connectedDevices: [String]) {
        print(connectedDevices)

    }

    func didReceiveData(service: DataTransferService, data: Data) {
        print(data)
    }
}
 */
