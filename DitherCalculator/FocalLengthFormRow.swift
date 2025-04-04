//
//  FocalLengthFormRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import CoreUI
import SwiftUI

struct FocalLengthFormRow: View {
    @Binding var value: Int?
    let onHeaderTap: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            LearnWhatThisIsFormRowButton {
                onHeaderTap()
            } label: {
                FocalLengthRowHeader()
            }
            TextField(0.formatted(), value: $value, format: .number)
                .keyboardType(.numberPad)
        }
    }
}

#Preview {
    FocalLengthFormRow(value: .constant(nil), onHeaderTap: {})
    FocalLengthFormRow(value: .constant(382), onHeaderTap: {})
}
