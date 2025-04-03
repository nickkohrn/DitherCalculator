//
//  LabeledConfigComponentRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

struct LabeledFocalLengthRow: View {
    let value: Measurement<UnitLength>?

    var body: some View {
        LabeledContent("Focal Length") {
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
            numberFormatStyle: .number.precision(.fractionLength(0)))
        )
    }
}

#Preview {
    LabeledFocalLengthRow(value: nil)
    LabeledFocalLengthRow(value: Measurement(value: 382, unit: .millimeters))
}
