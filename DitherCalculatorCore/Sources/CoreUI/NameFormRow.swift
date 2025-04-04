//
//  NameFormRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

public struct NameFormRow: View {
    @Binding private var value: String

    public init(value: Binding<String>) {
        self._value = value
    }

    public var body: some View {
        TextField("Name", text: $value)
            .autocapitalization(.words)
            .accessibilityLabel("Configuration Name")
    }
}

#Preview {
    NameFormRow(value: .constant(""))
    NameFormRow(value: .constant("Starfront Rig"))
}
