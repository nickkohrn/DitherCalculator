//
//  ConfigTests.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/3/25.
//

import CloudKit
import Foundation
import Models
import Testing

struct ConfigTests {

    @Test func configInitComputesExpectedComputedProperties() throws {
        let sut = Config(
            guidingFocalLength: FocalLength(value: 200),
            guidingPixelSize: PixelSize(value: 2.99),
            imagingFocalLength: FocalLength(value: 382),
            imagingPixelSize: 3.76,
            maxPixelShift: nil,
            name: nil,
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: nil
        )

        let guidingFocalLength = try #require(sut.guidingFocalLength)
        let guidingPixelSize = try #require(sut.guidingPixelSize)
        let imagingFocalLength = try #require(sut.imagingFocalLength)
        let imagingPixelSize = try #require(sut.imagingPixelSize)

        #expect(guidingFocalLength == FocalLength(value: 200))
        #expect(guidingPixelSize == PixelSize(value: 2.99))
        #expect(imagingFocalLength == FocalLength(value: 382))
        #expect(imagingPixelSize == PixelSize(value: 3.76))
    }

    @Test func configInitFromCKRecord() throws {
        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: Config.Key.type.rawValue, recordID: recordID)
        record[Config.Key.guidingFocalLength.rawValue] = 200
        record[Config.Key.guidingPixelSize.rawValue] = 2.99
        record[Config.Key.imagingFocalLength.rawValue] = 382
        record[Config.Key.imagingPixelSize.rawValue] = 3.76
        record[Config.Key.maxPixelShift.rawValue] = 10
        record[Config.Key.name.rawValue] = "Test"
        record[Config.Key.scale.rawValue] = 1

        let sut = try #require(Config(from: record))

        #expect(sut.guidingFocalLength == FocalLength(value: 200))
        #expect(sut.guidingPixelSize == PixelSize(value: 2.99))
        #expect(sut.imagingFocalLength == FocalLength(value: 382))
        #expect(sut.imagingPixelSize == PixelSize(value: 3.76))
        #expect(sut.maxPixelShift == 10)
        #expect(sut.name == "Test")
        #expect(sut.recordID == recordID)
        #expect(sut.scale == 1)
    }

    @Test func configCreatesNewCKRecord() throws {
        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let config = Config(
            guidingFocalLength: FocalLength(value: 200),
            guidingPixelSize: PixelSize(value: 2.99),
            imagingFocalLength: FocalLength(value: 382),
            imagingPixelSize: 3.76,
            maxPixelShift: 10,
            name: "Test",
            recordID: recordID,
            scale: 1
        )

        let sut = config.newCKRecord()
        let guidingFocalLength = try #require(sut[Config.Key.guidingFocalLength.rawValue] as? Int)
        let guidingPixelSize = try #require(sut[Config.Key.guidingPixelSize.rawValue] as? Double)
        let imagingFocalLength = try #require(sut[Config.Key.imagingFocalLength.rawValue] as? Int)
        let imagingPixelSize = try #require(sut[Config.Key.imagingPixelSize.rawValue] as? Double)
        let maxPixelShift = try #require(sut[Config.Key.maxPixelShift.rawValue] as? Int)
        let name = try #require(sut[Config.Key.name.rawValue] as? String)
        let scale = try #require(sut[Config.Key.scale.rawValue] as? Double)

        #expect(sut.recordType == "Config")
        #expect(sut.recordID == recordID)
        #expect(guidingFocalLength == 200)
        #expect(guidingPixelSize == 2.99)
        #expect(imagingFocalLength == 382)
        #expect(imagingPixelSize == 3.76)
        #expect(maxPixelShift == 10)
        #expect(name == "Test")
        #expect(scale == 1)
    }

    @Test func configUpdatesWithNewValuesFromConfig() throws {
        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let sut = Config(
            guidingFocalLength: FocalLength(value: 100),
            guidingPixelSize: PixelSize(value: 2.5),
            imagingFocalLength: FocalLength(value: 300),
            imagingPixelSize: 3.2,
            maxPixelShift: 5,
            name: "Original",
            recordID: recordID,
            scale: 0.5
        )

        let updated = Config(
            guidingFocalLength: FocalLength(value: 200),
            guidingPixelSize: PixelSize(value: 2.99),
            imagingFocalLength: FocalLength(value: 382),
            imagingPixelSize: 3.76,
            maxPixelShift: 10,
            name: "Updated",
            recordID: sut.recordID,
            scale: 1.0
        )

        sut.updateWithValues(from: updated)

        #expect(sut.guidingFocalLength == FocalLength(value: 200))
        #expect(sut.guidingPixelSize == PixelSize(value: 2.99))
        #expect(sut.imagingFocalLength == FocalLength(value: 382))
        #expect(sut.imagingPixelSize == PixelSize(value: 3.76))
        #expect(sut.maxPixelShift == 10)
        #expect(sut.name == "Updated")
        #expect(sut.recordID == recordID)
        #expect(sut.scale == 1.0)
    }
}
