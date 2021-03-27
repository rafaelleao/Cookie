import Foundation

struct KeyValuePair {
    public let key: String
    public let value: String?

    public init(_ key: String, _ value: String? = nil) {
        self.key = key
        self.value = value
    }
}

extension KeyValuePair: Equatable {
    public static func == (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

extension KeyValuePair: Comparable {
    public static func < (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        lhs.key.lowercased() < rhs.key.lowercased()
    }
}
