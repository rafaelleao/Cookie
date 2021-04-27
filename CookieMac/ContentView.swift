import SwiftUI
import Core

struct ConnectedDeviceRow: View {
    @ObservedObject var peer: ConnectedPeer

    var body: some View {
        Text(peer.peerId.displayName).foregroundColor(peer.connected ? .green : .orange)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()

    var body: some View {
        HStack {
            //Spacer()
            VStack {
                RequestList(viewModel: viewModel.requestListViewModel)//.frame(minWidth: 700, minHeight: 300)
                //Text(viewModel.browser.connectedPeers.first?.peerId.displayName ?? "")
                //if !(viewModel.connectedDevices?.isEmpty ?? true) {
                   // Text((viewModel.connectedDevices?.joined())!)
                //}
                List(viewModel.connectedDevices ?? [], id: \.self) { peer in
                    ConnectedDeviceRow(peer: peer)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import Combine
class ContentViewModel: ObservableObject {

    let browser: Browser
    var requestListViewModel = RequestListViewModel()
    private var bindings = [AnyCancellable]()
   // @Published var connectedDevices: [String]?
    @Published var connectedDevices: [ConnectedPeer]?

    init() {
        browser = Browser(deviceName: "MacOS")
        browser.delegate = self

        browser.$connectedPeers
            .receive(on: DispatchQueue.main)
            //.assign(to: \.connectedDevices, on: self)
            .sink { (peerIds) in
                //self.connectedDevices = peerIds.map( { $0.peerId.displayName })
                print(peerIds)
                self.connectedDevices = peerIds
            }.store(in: &bindings)
    }
}

extension ContentViewModel: DataTransferServiceDelegate {
    func didReceiveData(data: Data) {
        if let decodedData = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) {
            DispatchQueue.main.async {
                self.requestListViewModel.source = decodedData as! [HTTPRequest]
            }
        }
    }
}

