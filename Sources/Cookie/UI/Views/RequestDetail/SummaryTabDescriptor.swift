//
//  SummaryTabDescriptor.swift
//  Cookie
//
//  Created by Rafael Leão on 14.09.21.
//

import Foundation

struct SummaryTabDescriptor: TabDescriptor {
    let request: HTTPRequest

    var title: String {
        "Summary"
    }

    var image: String {
        "network"
    }
    
    func sections() -> [SectionData] {
        [SectionData(title: "", pairs: summary())]
    }

    func action() -> Action? {
        nil
    }

    private func summary() -> [KeyValuePair] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        let requestDate = dateFormatter.string(from: request.requestDate)

        var requestData: [KeyValuePair] = []
        requestData.append(KeyValuePair("Request date", requestDate))

        if let date = request.responseDate {
            let responseDate = dateFormatter.string(from: date)
            requestData.append(KeyValuePair("Response date", responseDate))
            let interval = String(format: "%.2f ms", date.timeIntervalSince(request.requestDate))
            requestData.append(KeyValuePair("Interval", interval))
        }

        if let method = request.urlRequest.httpMethod {
            requestData.append(KeyValuePair("Method", method))
        }

        requestData.append(KeyValuePair("Timeout", "\(request.urlRequest.timeoutInterval)"))

        if let response = request.response {
            var statusCode: Int?
            if case let .success(response, _) = response {
                statusCode = response.statusCode
            } else if case let .failure(response, error as NSError) = response {
                statusCode = response?.statusCode
                requestData.append(KeyValuePair("Error", "\(error.domain)(\(error.code)): \(error.localizedDescription)"))
            }
            if let status = statusCode {
                requestData.append(KeyValuePair("Status", "\(status)"))
            }
        }

        if let url = request.urlRequest.url {
            requestData.append(KeyValuePair("URL", url.absoluteString))
        }

        return requestData
    }
}
