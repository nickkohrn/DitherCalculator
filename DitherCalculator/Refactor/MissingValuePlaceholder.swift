//
//  MissingValuePlaceholder.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import SwiftUI

struct MissingValuePlaceholder: View {
    var body: some View {
        Text("--")
            .accessibilityLabel("No Value")
    }
}

#Preview {
    MissingValuePlaceholder()
}
