//
//  LoadingIndicator.swift
//  Cookie
//
//  Created by Rafael Leão on 12.09.21.
//

import SwiftUI

struct LoadingIndicator: View {
 
    @State private var isLoading = false
 
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 6)
                .frame(width: 16, height: 16)
            Circle()
                .trim(from: 0, to: 0.2)
                .stroke(Color.black, lineWidth: 4)
                .frame(width: 16, height: 16)
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                .onAppear() {
                    self.isLoading = true
            }
        }
    }
}
