//
//  LabeledConfigComponentRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

struct LabeledFocalLengthRow: View {
    let value: Int?

    var body: some View {
        LabeledContent("Focal Length") {
            if let value {
                Text(value.formatted())
            } else {
                MissingValuePlaceholder()
            }
        }
    }
}

#Preview {
    LabeledFocalLengthRow(value: nil)
    LabeledFocalLengthRow(value: 382)
}
