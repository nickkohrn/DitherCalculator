//
//  LabeledScaleRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

public struct LabeledScaleRow: View {
    public let value: Double?

    public init(value: Double?) {
        self.value = value
    }

    public var body: some View {
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
