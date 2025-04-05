//
//  EditConfigViewModelTests.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/4/25.
//

import CloudKit
import EditConfig
import Models
import Testing
import TestUtilities

@MainActor
struct SaveConfigViewModelTests {

    @Test func computesDisableSave() async throws {
        let sut = EditConfigViewModel()
        #expect(sut.disableSave)

        let config = Config(
            guidingFocalLength: FocalLength(value: 200),
            guidingPixelSize: PixelSize(value: 2.99),
            imagingFocalLength: FocalLength(value: 382),
            imagingPixelSize: PixelSize(value: 3.76),
            maxPixelShift: 10,
            name: "Test Config",
            recordID: CKRecord.ID(recordName: "Test"),
            scale: 1
        )
        sut.onAppear(with: config)
        #expect(sut.disableSave)

        sut.guidingFocalLength = 201
        #expect(!sut.disableSave)
        sut.guidingFocalLength = config.guidingFocalLength.value
        #expect(sut.disableSave)

        sut.guidingPixelSize = 2.98
        #expect(!sut.disableSave)
        sut.guidingPixelSize = config.guidingPixelSize.value
        #expect(sut.disableSave)

        sut.imagingFocalLength = 383
        #expect(!sut.disableSave)
        sut.imagingFocalLength = config.imagingFocalLength.value
        #expect(sut.disableSave)

        sut.imagingPixelSize = 3.77
        #expect(!sut.disableSave)
        sut.imagingPixelSize = config.imagingPixelSize.value
        #expect(sut.disableSave)

        sut.maxPixelShift = 11
        #expect(!sut.disableSave)
        sut.maxPixelShift = config.maxPixelShift
        #expect(sut.disableSave)

        sut.scale = 1.1
        #expect(!sut.disableSave)
        sut.scale = config.scale
        #expect(sut.disableSave)

        sut.name = "Test Config 2"
        #expect(!sut.disableSave)
        let name = try #require(config.name)
        sut.name = name
        #expect(sut.disableSave)

        config.name = nil
        sut.onAppear(with: config)
        sut.name = "Test Config 2"
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
        let sut = EditConfigViewModel()
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
        let sut = EditConfigViewModel()
        #expect(sut.result(for: config) == nil)
    }

    @Test func savesWithSuccess() async {
        let fakeRecord = CKRecord(recordType: CKRecord.RecordType("Config"))
        fakeRecord[Config.Key.name.rawValue] = "Updated Config"
        let stubService = StubSyncService(
            save: .success(()),
            recordForID: .success(fakeRecord)
        )

        let config = Config(
            guidingFocalLength: FocalLength(value: 200),
            guidingPixelSize: PixelSize(value: 2.99),
            imagingFocalLength: FocalLength(value: 382),
            imagingPixelSize: PixelSize(value: 3.76),
            maxPixelShift: 10,
            name: "Config",
            recordID: CKRecord.ID(recordName: "Test"),
            scale: 1
        )

        let sut = EditConfigViewModel()
        sut.onAppear(with: config)
        sut.name = "Updated Config"
        #expect(!sut.shouldDismiss)

        await confirmation() { confirmation in
            await sut.tappedSaveButton(
                for: config,
                syncService: stubService,
                onSuccess: { config in
                    #expect(config.name == "Updated Config")
                    #expect(sut.isSaving)
                    #expect(sut.shouldDismiss)
                    confirmation()
                }
            )
        }
    }

    @Test func saveWithFailure() async {
        let fakeRecord = CKRecord(recordType: CKRecord.RecordType("Config"))
        fakeRecord[Config.Key.name.rawValue] = "Updated Config"
        let stubService = StubSyncService(
            save: .failure(NSError(domain: #function, code: #line)),
            recordForID: .success(fakeRecord)
        )

        let config = Config(
            guidingFocalLength: FocalLength(value: 200),
            guidingPixelSize: PixelSize(value: 2.99),
            imagingFocalLength: FocalLength(value: 382),
            imagingPixelSize: PixelSize(value: 3.76),
            maxPixelShift: 10,
            name: "Config",
            recordID: CKRecord.ID(recordName: "Test"),
            scale: 1
        )

        let sut = EditConfigViewModel()
        sut.onAppear(with: config)
        sut.name = "Updated Config"
        #expect(!sut.shouldDismiss)

        await confirmation() { confirmation in
            await sut.tappedSaveButton(
                for: config,
                syncService: stubService,
                onSuccess: { _ in
                    Issue.record("Expected failure")
                }
            )
            #expect(!sut.isSaving)
            confirmation()
        }
    }
}
