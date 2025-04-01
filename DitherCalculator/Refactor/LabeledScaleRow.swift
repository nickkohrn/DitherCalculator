//
//  LabeledScaleRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

struct LabeledScaleRow: View {
    let value: Double?

    var body: some View {
        LabeledContent("Scale") {
            if let value {
                Text(value.formatted())
            } else {
                MissingValuePlaceholder()
            }
        }
    }
}

#Preview {
    LabeledScaleRow(value: nil)
    LabeledScaleRow(value: 3.76)
}
