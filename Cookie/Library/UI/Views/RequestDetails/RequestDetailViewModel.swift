//
//  RequestDetailViewModel.swift
//  Cookie
//
//  Created by Rafael Leão on 14.09.21.
//

import Core
import Combine

class RequestDetailViewModel: ObservableObject {
    let request: HTTPRequest

    init(request: HTTPRequest) {
        self.request = request
    }

    var title: String {
        request.urlRequest.url?.host ?? "Request Details"
    }

    func tabDescriptors() -> [TabDescriptor] {
        [
            SummaryTabDescriptor(request: request),
            RequestTabDescriptor(request: request),
            ResponseTabDescriptor(request: request)
        ]
    }
}
