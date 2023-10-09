//
//  RequestDetailViewModel.swift
//  Cookie
//
//  Created by Rafael Leão on 14.09.21.
//

import Combine

class RequestDetailViewModel: ObservableObject {
    let request: HTTPRequest
    @Published var searchText: String = ""
    private var bindings: [AnyCancellable] = []

    init(request: HTTPRequest) {
        self.request = request
        $searchText.sink { newValue in
            self.childViewModels.forEach { viewModel in
                viewModel.searchText =  newValue
            }
        }.store(in: &bindings)
    }

    var title: String {
        request.urlRequest.url?.host ?? "Request Details"
    }

    lazy var tabDescriptors: [TabDescriptor] = {
        [
            SummaryTabDescriptor(request: request),
            RequestTabDescriptor(request: request),
            ResponseTabDescriptor(request: request)
        ]
    }()

    lazy var childViewModels: [RequestDetailTabViewModel] = {
        tabDescriptors.map {
            RequestDetailTabViewModel(descriptor: $0)
        }
    }()
}
