//
//  SwiftUIView.swift
//  
//
//  Created by Rafael Leão on 23.10.23.
//

import SwiftUI

struct SearchBar: View {
    private let placeholder: String
    @Binding private var text: String

    init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .padding(.leading, 6)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .frame(height: 22)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
            }
        }
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
//                .stroke(.separator, lineWidth: 1)
        )
    }
}

#Preview("Empty") {
    SearchBar(placeholder: "Search", text: .constant(""))
        .padding()
}

#Preview("Search keyword") {
    SearchBar(placeholder: "Search", text: .constant("keyword"))
        .padding()
}
