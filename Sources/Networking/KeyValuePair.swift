import Foundation

public struct KeyValuePair: Equatable, Comparable {
    public let key: String
    public let value: String?

    public init(_ key: String, _ value: String? = nil) {
        self.key = key
        self.value = value
    }

    public static func == (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        lhs.key == rhs.key && lhs.value == rhs.value
    }

    public static func < (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        lhs.key.lowercased() < rhs.key.lowercased()
    }
}
