//
//  LabeledPixelShiftRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

public struct LabeledMaxPixelShiftRow: View {
    public let value: Int?

    public init(value: Int?) {
        self.value = value
    }

    public var body: some View {
        LabeledContent("Max Pixel Shift") {
            if let value {
                Text("^[\(value) pixel](inflect: true)")
            } else {
                MissingValuePlaceholder()
            }
        }
    }
}

#Preview {
    LabeledMaxPixelShiftRow(value: nil)
    LabeledMaxPixelShiftRow(value: 10)
}
