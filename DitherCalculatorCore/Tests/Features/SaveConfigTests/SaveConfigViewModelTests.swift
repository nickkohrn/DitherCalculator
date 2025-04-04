//
//  SaveConfigViewModelTests.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/4/25.
//

import SaveConfig
import Testing

@MainActor
struct SaveConfigViewModelTests {

    @Test func computesDisableSave() async throws {
        let sut = SaveConfigViewModel()
        sut.name = "  "
        #expect(sut.disableSave)

        sut.name = "Test"
        #expect(!sut.disableSave)
    }

}
