//
//  SaveConfigViewModelTests.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/4/25.
//

import CloudKit
import Models
import SaveConfig
import Testing
import TestUtilities

@MainActor
struct SaveConfigViewModelTests {

    @Test func computesDisableSave() async throws {
        let sut = SaveConfigViewModel()
        sut.name = "  "
        #expect(sut.disableSave)

        sut.name = "Test"
        #expect(!sut.disableSave)
    }

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
        let sut = SaveConfigViewModel()
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
        let sut = SaveConfigViewModel()
        #expect(sut.result(for: config) == nil)
    }

    @Test func savesWithSuccess() async {
        let stubService = StubSyncService(save: .success(()))

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

        let sut = SaveConfigViewModel()
        #expect(sut.name == "")
        #expect(!sut.shouldDismiss)

        sut.name = " New Config "
        await sut.tappedSaveButton(for: config, syncService: stubService)

        #expect(config.name == "New Config")
        #expect(sut.isSaving)
        #expect(sut.shouldDismiss)
    }

    @Test func savesWithSuccessWithNilName() async {
        let stubService = StubSyncService(save: .success(()))

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

        let sut = SaveConfigViewModel()
        #expect(sut.name == "")
        #expect(!sut.shouldDismiss)

        await sut.tappedSaveButton(for: config, syncService: stubService)

        #expect(config.name == nil)
        #expect(sut.isSaving)
        #expect(sut.shouldDismiss)
    }

    @Test func savesWithFailure() async {
        let stubService = StubSyncService(save: .failure(NSError(domain: #function, code: #line)))

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

        let sut = SaveConfigViewModel()
        #expect(sut.name == "")
        #expect(!sut.shouldDismiss)

        await sut.tappedSaveButton(for: config, syncService: stubService)

        #expect(config.name == nil)
        #expect(!sut.isSaving)
        #expect(!sut.shouldDismiss)
    }
}
