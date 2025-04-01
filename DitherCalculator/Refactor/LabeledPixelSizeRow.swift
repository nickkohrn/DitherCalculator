//
//  LabeledImagingPixelSizeRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

struct LabeledPixelSizeRow: View {
    let value: Double?

    var body: some View {
        LabeledContent("Pixel Size") {
            if let value {
                Text(value.formatted())
            } else {
                MissingValuePlaceholder()
            }
        }
    }
}

#Preview {
    LabeledPixelSizeRow(value: nil)
    LabeledPixelSizeRow(value: 3.76)
}
