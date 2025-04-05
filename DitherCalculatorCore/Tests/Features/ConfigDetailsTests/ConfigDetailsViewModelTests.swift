//
//  File.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/5/25.
//

import CloudKit
import ConfigDetails
import EditConfig
import Models
import Testing
import TestUtilities

@MainActor
struct ConfigDetailsViewModelTests {

    @Test func computesResult() {
        let config = Config(
            guidingFocalLength: FocalLength(value: 200),
            guidingPixelSize: PixelSize(value: 2.99),
            imagingFocalLength: FocalLength(value: 382),
            imagingPixelSize: PixelSize(value: 3.76),
            maxPixelShift: 10,
            name: nil,
            recordID: CKRecord.ID(recordName: "Test"),
            scale: 1
        )
        let sut = ConfigDetailsViewModel(didDeleteConfig: { _ in
            Issue.record("Did not expect deletion")
        })
        #expect(sut.result(for: config) == DitherResult(pixels: 7))
    }

    @Test func computesNilResult() {
        let config = Config(
            guidingFocalLength: FocalLength(value: nil),
            guidingPixelSize: PixelSize(value: nil),
            imagingFocalLength: FocalLength(value: nil),
            imagingPixelSize: PixelSize(value: nil),
            maxPixelShift: nil,
            name: nil,
            recordID: CKRecord.ID(recordName: "Test"),
            scale: nil
        )
        let sut = ConfigDetailsViewModel(didDeleteConfig: { config in
            Issue.record("Did not expect deletion")
        })
        #expect(sut.result(for: config) == nil)
    }

    @Test func tappedDeleteButton() {
        let sut = ConfigDetailsViewModel(didDeleteConfig: { config in
            Issue.record("Did not expect deletion")
        })
        #expect(!sut.isShowingDeleteConfirmationDialog)
        sut.tappedDeleteButton()
        #expect(sut.isShowingDeleteConfirmationDialog)
    }

    @Test func tappedDeleteConfirmationCancelButton() {
        
    }
}
