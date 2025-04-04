//
//  MissingValuePlaceholder.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import SwiftUI

public struct MissingValuePlaceholder: View {
    public init() {}

    public var body: some View {
        Text("--")
            .accessibilityLabel("No Value")
    }
}

#Preview {
    MissingValuePlaceholder()
}
