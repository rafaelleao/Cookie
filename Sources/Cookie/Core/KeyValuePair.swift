import Foundation

struct KeyValuePair {
    let key: String
    let value: String?

    init(_ key: String, _ value: String? = nil) {
        self.key = key
        self.value = value
    }
}

extension KeyValuePair: Equatable {
    static func == (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        lhs.key == rhs.key && lhs.value == rhs.value
    }
}

extension KeyValuePair: Comparable {
    static func < (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        lhs.key.lowercased() < rhs.key.lowercased()
    }
}
