//
//  RequestDetailTabViewModel.swift
//  Cookie
//
//  Created by Rafael Leão on 14.09.21.
//

import Combine
import Foundation

struct SectionData {
    let id = UUID()
    let title: String
    let pairs: [KeyValuePair]
}

extension SectionData: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

protocol TabDescriptor {
    init(request: HTTPRequest)
    var request: HTTPRequest { get }
    var title: String { get }
    var image: String { get }
    func sections() -> [SectionData]
    func action() -> Action?
}

class Action {
    let title: String
    let handler: () -> TextViewerViewModel

    init(title: String, handler: @escaping (() -> TextViewerViewModel)) {
        self.title = title
        self.handler = handler
    }
}

class RequestDetailTabViewModel: ObservableObject {
    @Published var data: [SectionData] = []
    @Published var searchText: String = ""
    @Published var action: Action?
    @Published var isLoading: Bool
    private(set) var title: String
    private(set) var image: String

    private var sections: [SectionData]
    private var bindings: [AnyCancellable] = []

    init(descriptor: TabDescriptor) {
        self.sections = descriptor.sections()
        self.action = descriptor.action()
        self.title = descriptor.title
        self.image = descriptor.image
        self.isLoading = descriptor.request.response == nil
        if isLoading {
            descriptor.request.$response
                .receive(on: RunLoop.main)
                .dropFirst()
                .sink { _ in
                    self.isLoading = false
                    self.sections = descriptor.sections()
                    self.filter(searchString: self.searchText)
                }
                .store(in: &bindings)
        }
        $searchText.sink { [unowned self] text in
            print(text)
            self.filter(searchString: text)
        }.store(in: &bindings)
    }

    private func filter(searchString: String) {
        if searchString.isEmpty {
            data = sections
            return
        }
        var results: [SectionData] = []
        for section in sections {
            var pairs: [KeyValuePair] = []
            for pair in section.pairs {
                if pair.key.lowercased().range(of: searchString.lowercased()) != nil || pair.value?.lowercased().range(of: searchString.lowercased()) != nil {
                    pairs.append(pair)
                }
            }
            let section = SectionData(title: section.title, pairs: pairs)
            results.append(section)
        }
        data = results
    }
}
