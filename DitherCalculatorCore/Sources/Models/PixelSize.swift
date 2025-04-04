//
//  PixelSize.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import Foundation
import Observation

@Observable
public final class PixelSize {
    public static let unit: UnitLength = .micrometers
    public var value: Double?

    public var measurement: Measurement<UnitLength> {
        guard let value else { return Measurement(value: 0, unit: Self.unit) }
        return Measurement(value: value, unit: Self.unit)
    }

    public init(value: Double?) {
        self.value = value
    }
}

extension PixelSize: Equatable {
    public static func == (lhs: PixelSize, rhs: PixelSize) -> Bool {
        lhs.value == rhs.value
    }
}

extension PixelSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
