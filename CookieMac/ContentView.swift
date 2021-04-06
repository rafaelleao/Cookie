import SwiftUI
import Core

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()

    var body: some View {
        HStack {
            //Spacer()
            RequestList(viewModel: viewModel.requestListViewModel)//.frame(minWidth: 700, minHeight: 300)
            //TextViewer(viewModel: TextViewerViewModel(text: "bla bla", filename: "fil"))


        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


class ContentViewModel: ObservableObject {

    let dataTransferService: DataTransferService
    var requestListViewModel = RequestListViewModel()

    init() {
        dataTransferService = DataTransferService(deviceName: "MacOS")
        dataTransferService.delegate = self
    }
}

extension ContentViewModel: DataTransferServiceDelegate {
    func connectedDevicesChanged(service: DataTransferService, connectedDevices: [String]) {
        print(connectedDevices)
    }

    func didReceiveData(service: DataTransferService, data: Data) {
        if let decodedData = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) {
            requestListViewModel.source = decodedData as! [HTTPRequest]
        }
    }
}
