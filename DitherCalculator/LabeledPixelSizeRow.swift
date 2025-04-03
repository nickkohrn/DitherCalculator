//
//  LabeledImagingPixelSizeRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

struct LabeledPixelSizeRow: View {
    let value: Measurement<UnitLength>?

    var body: some View {
        LabeledContent("Pixel Size") {
            if let value {
                Text(formatted(value: value, width: .abbreviated))
                    .accessibilityLabel(formatted(value: value, width: .wide))
            } else {
                MissingValuePlaceholder()
            }
        }
    }

    private func formatted(
        value: Measurement<UnitLength>,
        width: Measurement<UnitLength>.FormatStyle.UnitWidth
    ) -> String {
        value.formatted(.measurement(
            width: width,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(0...2)))
        )
    }
}

#Preview {
    LabeledPixelSizeRow(value: nil)
    LabeledPixelSizeRow(value: Measurement(value: 3.76, unit: .micrometers))
}
