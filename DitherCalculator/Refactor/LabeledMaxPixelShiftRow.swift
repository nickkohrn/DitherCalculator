//
//  LabeledPixelShiftRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

struct LabeledMaxPixelShiftRow: View {
    let value: Int?

    var body: some View {
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
