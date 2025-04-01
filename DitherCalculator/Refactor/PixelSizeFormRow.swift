//
//  PixelSizeFormRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

struct PixelSizeFormRow: View {
    @Binding var value: Double?
    let onHeaderTap: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            LearnWhatThisIsFormRowButton {
                onHeaderTap()
            } label: {
                PixelSizeRowHeader()
            }
            TextField(0.formatted(), value: $value, format: .number)
                .keyboardType(.decimalPad)
        }
    }
}

#Preview {
    PixelSizeFormRow(value: .constant(nil), onHeaderTap: {})
    PixelSizeFormRow(value: .constant(3.76), onHeaderTap: {})
}
