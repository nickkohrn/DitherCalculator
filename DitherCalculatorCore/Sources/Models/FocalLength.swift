//
//  FocalLength.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import Foundation

public struct FocalLength: Equatable {
    public typealias Unit = UnitLength
    public static let unit: Self.Unit = .millimeters
    public let measurement: Measurement<Self.Unit>

    public init(value: Int) {
        measurement = Measurement(value: Double(value), unit: Self.unit)
    }
}
