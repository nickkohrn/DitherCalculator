//
//  PixelSizeRowHeader.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//

import CoreUI
import Models
import SwiftUI

public struct PixelSizeRowHeader: View {
    public var body: some View {
        FormRowHeader(string: "Pixel Size", parenthesizedString: PixelSize.unit.symbol)
            .accessibilityLabel("Pixel size in \(MeasurementFormatter.longUnitFormatter.string(from: PixelSize.unit))")
    }
}

#Preview {
    PixelSizeRowHeader()
}
