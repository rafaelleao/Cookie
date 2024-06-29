import Foundation

public extension String {
    func contains(_ searchString: String) -> Bool {
        lowercased().range(of: searchString.lowercased()) != nil
    }
}
