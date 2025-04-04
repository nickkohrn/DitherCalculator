//
//  MaxPixelShiftFormRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import CoreUI
import SwiftUI

struct MaxPixelShiftFormRow: View {
    @Binding var value: Int?
    let onHeaderTap: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            LearnWhatThisIsFormRowButton {
                onHeaderTap()
            } label: {
                MaxPixelShiftRowHeader()
            }
            .maxShiftInPixelsAccessibilityLabel()
            TextField(0.formatted(), value: $value, format: .number)
                .keyboardType(.numberPad)
        }
    }
}

#Preview {
    MaxPixelShiftFormRow(value: .constant(nil), onHeaderTap: {})
    MaxPixelShiftFormRow(value: .constant(10), onHeaderTap: {})
}
