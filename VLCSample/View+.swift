import SwiftUI

extension View {
    
    // We need this modifier to handle the iOS version compatibility
    @ViewBuilder
    func onValueChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (V, V) -> Void
    ) -> some View where V : Equatable {
        if #available(iOS 17, *) {
            onChange(of: value, initial: initial, action)
        } else {
            onChange(of: value) { [value] newValue in
                action(value, newValue)
            }
        }
    }
}
