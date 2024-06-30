import Foundation

extension String {
    func contains(_ searchString: String) -> Bool {
        lowercased().range(of: searchString.lowercased()) != nil
    }
}
