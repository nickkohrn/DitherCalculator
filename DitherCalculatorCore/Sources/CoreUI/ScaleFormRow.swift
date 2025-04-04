//
//  ScaleFormRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

public struct ScaleFormRow: View {
    @Binding private var value: Double?
    private let onHeaderTap: () -> Void

    public init(value: Binding<Double?>, onHeaderTap: @escaping () -> Void) {
        self._value = value
        self.onHeaderTap = onHeaderTap
    }

    public var body: some View {
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
