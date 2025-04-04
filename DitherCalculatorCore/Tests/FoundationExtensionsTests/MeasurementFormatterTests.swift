//
//  MeasurementFormatterTests.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import Foundation
import FoundationExtensions
import Testing

struct MeasurementFormatterTests {

    @MainActor @Test
    func longUnitMeasurementFormatterReturnsExpectedString() async throws {
        let sut = MeasurementFormatter.longUnitFormatter.string(from: UnitLength.millimeters)
        #expect(sut == "millimeters")
    }

}
