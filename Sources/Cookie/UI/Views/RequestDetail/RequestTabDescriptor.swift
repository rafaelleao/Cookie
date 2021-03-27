//
//  RequestTabDescriptor.swift
//  Cookie
//
//  Created by Rafael Leão on 13.09.21.
//

import Foundation

class RequestTabDescriptor: TabDescriptor {
    let request: HTTPRequest

    required init(request: HTTPRequest) {
        self.request = request
    }

    var title: String {
        "Request"
    }

    func sections() -> [SectionData] {
        [
            SectionData(title: "Request Headers", pairs: headers()),
            SectionData(title: "Query Parameters", pairs: queryParams())
        ]
    }

    func action() -> Action? {
        if canShowRequestBody(), let viewModel = textViewerViewModel() {
            return Action(title: "View Request Body") {
                viewModel
            }
        }
        return nil
    }

    private func canShowRequestBody() -> Bool {
        return request.requestBodyString != nil
    }

    private func textViewerViewModel() -> TextViewerViewModel? {
        guard let body = request.requestBodyString else {
            return nil
        }
        let viewModel = TextViewerViewModel(text: body, filename: "")
        return viewModel
    }

    private func headers() -> [KeyValuePair] {
        var pairs: [KeyValuePair] = []
        if let allHTTPHeaderFields = request.urlRequest.allHTTPHeaderFields {
            for (key, value) in allHTTPHeaderFields {
                pairs.append(KeyValuePair(key, value))
            }
        }

        return pairs.sorted()
    }

    private func queryParams() -> [KeyValuePair] {
        var pairs: [KeyValuePair] = []

        if let url = request.urlRequest.url,
           let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = urlComponents.queryItems, !queryItems.isEmpty {
            for param in queryItems {
                pairs.append(KeyValuePair(param.name, param.value ?? ""))
            }
        }

        return pairs.sorted()
    }
}
