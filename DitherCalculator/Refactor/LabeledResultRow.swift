//
//  ResultRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import SwiftUI

struct LabeledResultRow: View {
    let result: Int?

    var body: some View {
        LabeledContent("Result") {
            if let result {
                Text("^[\(result) pixel](inflect: true)")
            } else {
                MissingValuePlaceholder()
            }
        }
    }
}

#Preview {
    LabeledResultRow(result: nil)
    LabeledResultRow(result: 1)
    LabeledResultRow(result: 10)
}
