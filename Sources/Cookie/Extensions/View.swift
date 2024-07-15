import SwiftUI

@available(iOS 16.0, *)
@available(macOS 13.0, *)
extension View {
    @ViewBuilder
    func modify(@ViewBuilder _ transform: (Self) -> (some View)?) -> some View {
        if let view = transform(self), !(view is EmptyView) {
            view
        } else {
            self
        }
    }

}
