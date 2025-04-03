//
//  ScaleFormRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

struct ScaleFormRow: View {
    @Binding var value: Double?
    let onHeaderTap: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            LearnWhatThisIsFormRowButton {
                onHeaderTap()
            } label: {
                ScaleRowHeader()
            }
            TextField(0.formatted(), value: $value, format: .number)
                .keyboardType(.decimalPad)
        }
    }
}

#Preview {
    ScaleFormRow(value: .constant(nil), onHeaderTap: {})
    ScaleFormRow(value: .constant(1), onHeaderTap: {})
}
