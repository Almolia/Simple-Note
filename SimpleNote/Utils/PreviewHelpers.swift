//
//  PreviewHelpers.swift
//  SimpleNote
//
//  Created by Ali M.Sh on 5/2/1404 AP.
//

import SwiftUI

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    var content: (Binding<Value>) -> Content

    init(_ initialValue: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}

struct MyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .keyboardType(.default)
            .autocapitalization(.none)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
    }
}
