//
//  NameFormRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

struct NameFormRow: View {
    @Binding var value: String

    var body: some View {
        TextField("Name", text: $value)
            .autocapitalization(.words)
            .accessibilityLabel("Configuration Name")
    }
}

#Preview {
    NameFormRow(value: .constant(""))
    NameFormRow(value: .constant("Starfront Rig"))
}
