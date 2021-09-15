//
//  ResponseTabDescriptor.swift
//  Cookie
//
//  Created by Rafael Leão on 13.09.21.
//

import Foundation

class ResponseTabDescriptor: TabDescriptor {
    let request: HTTPRequest

    required init(request: HTTPRequest) {
        self.request = request
    }
    
    var title: String {
        "Response"
    }

    func sections() -> [SectionData] {
        [SectionData(title: "Response Headers", pairs: headers())]
    }
    
    func action() -> Action? {
        if canShowResponse(), let viewModel = textViewerViewModel() {
            return Action(title: "View Response") {
                viewModel
            }
        }
        return nil
    }

    private func headers() -> [KeyValuePair] {
        var headers: [KeyValuePair] = []
        if let allHeaders = request.response?.urlResponse?.allHeaderFields {
            for (key, value) in allHeaders {
                headers.append(KeyValuePair(key.description, value as? String))
            }
        }

        return headers.sorted()
    }

    private func canShowResponse() -> Bool {
        return responseString()?.isEmpty != nil
    }

    private func textViewerViewModel() -> TextViewerViewModel? {
        guard let response = responseString() else {
            return nil
        }
        let viewModel = TextViewerViewModel(text: response, filename: suggestedFilename() ?? "")
        return viewModel
    }

    private func suggestedFilename() -> String? {
        guard case .success(let response, _)? = request.response else {
            return nil
        }
        return response.suggestedFilename
    }

    private func responseString() -> String? {
        request.response?.responseString
    }
}
