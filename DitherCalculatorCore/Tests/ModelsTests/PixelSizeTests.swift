//
//  FocalLengthTests.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import Foundation
import Models
import Testing

struct PixelSizeTests {

    @Test func pixelSizeInitCreatesExpectedMeasurement() async throws {
        let sut = PixelSize(value: 3.76)
        #expect(sut.measurement == Measurement<UnitLength>(value: 3.76, unit: .micrometers))
    }

}
