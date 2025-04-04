//
//  FocalLengthFormRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

public struct FocalLengthFormRow: View {
    @Binding private var value: Int?
    private let onHeaderTap: () -> Void

    public init(value: Binding<Int?>, onHeaderTap: @escaping () -> Void) {
        self._value = value
        self.onHeaderTap = onHeaderTap
    }

    public var body: some View {
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
