//
//  PixelSize.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import Foundation

public struct PixelSize: Equatable {
    public typealias Unit = UnitLength
    public static let unit: Self.Unit = .micrometers
    public let measurement: Measurement<Self.Unit>

    public init(value: Double) {
        measurement = Measurement(value: value, unit: Self.unit)
    }
}
