//
//  FocalLength.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import Foundation
import Observation

@Observable
public final class FocalLength {
    public static let unit: UnitLength = .millimeters
    public var value: Int?

    public var measurement: Measurement<UnitLength> {
        guard let value else { return Measurement(value: 0, unit: Self.unit)}
        return Measurement(value: Double(value), unit: Self.unit)
    }

    public init(value: Int?) {
        self.value = value
    }
}

extension FocalLength: Equatable {
    public static func == (lhs: FocalLength, rhs: FocalLength) -> Bool {
        lhs.value == rhs.value
    }
}

extension FocalLength: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
