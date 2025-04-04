//
//  Config.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation

// TODO: Change recordID from CKRecord.ID to UUID
// This will preven the need to import CloudKit in view files for use in #Preview
@Observable
public final class Config {
    public enum Key: String {
        case guidingFocalLength
        case guidingPixelSize
        case imagingFocalLength
        case imagingPixelSize
        case maxPixelShift
        case name
        case scale
        case type = "Config"
    }

    public var guidingFocalLength = FocalLength(value: nil)
    public var guidingPixelSize = PixelSize(value: nil)
    public var imagingFocalLength = FocalLength(value: nil)
    public var imagingPixelSize = PixelSize(value: nil)
    public var maxPixelShift: Int?
    public var name: String?
    public let recordID: CKRecord.ID
    public var scale: Double?

    public init(
        guidingFocalLength: FocalLength,
        guidingPixelSize: PixelSize,
        imagingFocalLength: FocalLength,
        imagingPixelSize: PixelSize,
        maxPixelShift: Int?,
        name: String?,
        recordID: CKRecord.ID,
        scale: Double?
    ) {
        self.guidingFocalLength = guidingFocalLength
        self.guidingPixelSize = guidingPixelSize
        self.imagingFocalLength = imagingFocalLength
        self.imagingPixelSize = imagingPixelSize
        self.maxPixelShift = maxPixelShift
        self.name = name
        self.recordID = recordID
        self.scale = scale
    }
}

extension Config: Identifiable {
    public var id: CKRecord.ID { recordID }
}

extension Config {
    public convenience init?(from record: CKRecord) {
        self.init(
            guidingFocalLength: FocalLength(value: record[Config.Key.guidingFocalLength.rawValue] as? Int),
            guidingPixelSize: PixelSize(value: record[Config.Key.guidingPixelSize.rawValue] as? Double),
            imagingFocalLength: FocalLength(value: record[Config.Key.imagingFocalLength.rawValue] as? Int),
            imagingPixelSize: PixelSize(value: record[Config.Key.imagingPixelSize.rawValue] as? Double),
            maxPixelShift: record[Config.Key.maxPixelShift.rawValue] as? Int,
            name: record[Config.Key.name.rawValue] as? String,
            recordID: record.recordID,
            scale: record[Config.Key.scale.rawValue] as? Double
        )
    }

    public func newCKRecord() -> CKRecord {
        let record = CKRecord(recordType: Config.Key.type.rawValue, recordID: recordID)
        record[Config.Key.guidingFocalLength.rawValue] = guidingFocalLength.value
        record[Config.Key.guidingPixelSize.rawValue] = guidingPixelSize.value
        record[Config.Key.imagingFocalLength.rawValue] = imagingFocalLength.value
        record[Config.Key.imagingPixelSize.rawValue] = imagingPixelSize.value
        record[Config.Key.maxPixelShift.rawValue] = maxPixelShift
        record[Config.Key.name.rawValue] = name
        record[Config.Key.scale.rawValue] = scale
        return record
    }
}

extension Config {
    public func updateWithValues(from config: Config) {
        guidingFocalLength = FocalLength(value: config.guidingFocalLength.value)
        guidingPixelSize = PixelSize(value: config.guidingPixelSize.value)
        imagingFocalLength = FocalLength(value: config.imagingFocalLength.value)
        imagingPixelSize = PixelSize(value: config.imagingPixelSize.value)
        maxPixelShift = config.maxPixelShift
        name = config.name
        scale = config.scale
    }
}
