//
//  FocalLengthRowHeader.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//

import Models
import SwiftUI

public struct FocalLengthRowHeader: View {
    public var body: some View {
        FormRowHeader(string: "Focal Length", parenthesizedString: FocalLength.unit.symbol)
            .accessibilityLabel("Focal length in \(MeasurementFormatter.longUnitFormatter.string(from: FocalLength.unit))")
    }
}

#Preview {
    FocalLengthRowHeader()
}
