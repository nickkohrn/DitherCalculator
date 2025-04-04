//
//  ResultRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import Models
import SwiftUI

public struct LabeledResultRow: View {
    private let result: DitherResult?

    public init(result: DitherResult?) {
        self.result = result
    }

    public var body: some View {
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
