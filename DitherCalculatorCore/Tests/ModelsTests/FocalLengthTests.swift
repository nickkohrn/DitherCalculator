//
//  FocalLengthTests.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import Foundation
import Models
import Testing

struct FocalLengthTests {

    @Test func focalLengthInitCreatesExpectedMeasurement() async throws {
        let sut = FocalLength(value: 382)
        #expect(sut.measurement == Measurement<UnitLength>(value: 382, unit: .millimeters))
    }

}
