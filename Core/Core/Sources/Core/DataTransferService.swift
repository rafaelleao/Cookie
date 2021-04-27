import Foundation
import MultipeerConnectivity
import Combine

public protocol DataTransferServiceDelegate {
  //  func connectedDevicesChanged(service: DataTransferService, connectedDevices: [String])
    func didReceiveData(data: Data)
}

public class ConnectedPeer: ObservableObject {
    @Published public var peerId: MCPeerID
    @Published public var connected: Bool

    public init(peerId: MCPeerID, connected: Bool) {
        self.peerId = peerId
        self.connected = connected
    }
}

extension ConnectedPeer: Hashable {
    
    public static func == (lhs: ConnectedPeer, rhs: ConnectedPeer) -> Bool {
        lhs.peerId == rhs.peerId && lhs.connected == rhs.connected
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(peerId)
        hasher.combine(connected)
    }
}

extension ConnectedPeer: CustomStringConvertible {
    public var description: String {
        "displayName: \(peerId.displayName), connected: \(connected)"
    }
}

public class Peer: NSObject {
    internal static let serviceType = "cookie"
    internal let peerId: MCPeerID
    @Published public var connectedPeers: [ConnectedPeer] = []
    public var delegate : DataTransferServiceDelegate?

    public init(deviceName: String) {
        self.peerId = MCPeerID(displayName: deviceName)
    }

    internal lazy var session : MCSession = {
        let session = MCSession(peer: self.peerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()

    func updatePeerState(peerId: MCPeerID, state: MCSessionState) {
        DispatchQueue.main.async { [unowned self] in
            if let peer = connectedPeers.first(where: { peer in
                peer.peerId == peerId
            }) {
                peer.connected = state == .connected
                print("peer updated \(peer)")
            } else {
                connectedPeers.append(ConnectedPeer(peerId: peerId, connected: state == .connected))
            }
        }
    }
}

public class Browser: Peer  {
    private lazy var serviceBrowser : MCNearbyServiceBrowser = {
        MCNearbyServiceBrowser(peer: peerId, serviceType: Browser.serviceType)
    }()

    public override init(deviceName: String) {
        super.init(deviceName: deviceName)

        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }

    deinit {
        self.serviceBrowser.stopBrowsingForPeers()
    }
}

public class Advertiser: Peer  {

    private lazy var serviceAdvertiser : MCNearbyServiceAdvertiser = {
         MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: Browser.serviceType)
    }()

    public override init(deviceName: String) {
        super.init(deviceName: deviceName)

        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
    }

    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }

    public func sendData(_ data: Data, peerId: MCPeerID) -> Bool {
        NSLog("%@", "sending data to \(session.connectedPeers.count) peers")

        //if session.connectedPeers.count > 0 {
            do {
                try self.session.send(data, toPeers: [peerId], with: .reliable)
                return true
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
                return false
            }
       // }
    }
}

extension Advertiser: MCNearbyServiceAdvertiserDelegate {

    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }

    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}

extension Browser: MCNearbyServiceBrowserDelegate {

    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }

    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        updatePeerState(peerId: peerID, state: .notConnected)
    }
}

extension Peer: MCSessionDelegate {

    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
       // self.delegate?.connectedDevicesChanged(service: self, connectedDevices:
         //   session.connectedPeers.map{$0.displayName})
        //connectedPeers = session.connectedPeers
        updatePeerState(peerId: peerID, state: state)
    }

    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        self.delegate?.didReceiveData(data: data)
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
}
