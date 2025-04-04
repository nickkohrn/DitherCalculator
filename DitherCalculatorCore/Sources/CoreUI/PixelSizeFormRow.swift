//
//  PixelSizeFormRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

public struct PixelSizeFormRow: View {
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
