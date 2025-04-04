//
//  ResultRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import Models
import SwiftUI

struct LabeledResultRow: View {
    let result: DitherResult?

    var body: some View {
        LabeledContent("Result") {
            if let result {
                DitherResultText(result: result)
            } else {
                MissingValuePlaceholder()
            }
        }
    }
}

#Preview {
    LabeledResultRow(result: nil)
    LabeledResultRow(result: DitherResult(pixels: 1))
    LabeledResultRow(result: DitherResult(pixels: 10))
}
