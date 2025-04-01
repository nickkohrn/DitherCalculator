//
//  Config.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation

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

    public var guidingFocalLength: Int?
    public var guidingPixelSize: Double?
    public var imagingFocalLength: Int?
    public var imagingPixelSize: Double?
    public var maxPixelShift: Int?
    public var name: String?
    public let recordID: CKRecord.ID
    public var scale: Double?

    public init(
        guidingFocalLength: Int?,
        guidingPixelSize: Double?,
        imagingFocalLength: Int?,
        imagingPixelSize: Double?,
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
            guidingFocalLength: record[Config.Key.guidingFocalLength.rawValue] as? Int,
            guidingPixelSize: record[Config.Key.guidingPixelSize.rawValue] as? Double,
            imagingFocalLength: record[Config.Key.imagingFocalLength.rawValue] as? Int,
            imagingPixelSize: record[Config.Key.imagingPixelSize.rawValue] as? Double,
            maxPixelShift: record[Config.Key.maxPixelShift.rawValue] as? Int,
            name: record[Config.Key.name.rawValue] as? String,
            recordID: record.recordID,
            scale: record[Config.Key.scale.rawValue] as? Double
        )
    }

    public func newCKRecord() -> CKRecord {
        let record = CKRecord(recordType: Config.Key.type.rawValue)
        record[Config.Key.guidingFocalLength.rawValue] = guidingFocalLength
        record[Config.Key.guidingPixelSize.rawValue] = guidingPixelSize
        record[Config.Key.imagingFocalLength.rawValue] = imagingFocalLength
        record[Config.Key.imagingPixelSize.rawValue] = imagingPixelSize
        record[Config.Key.maxPixelShift.rawValue] = maxPixelShift
        record[Config.Key.name.rawValue] = name
        record[Config.Key.scale.rawValue] = scale
        return record
    }
}

extension Config {
    func updateWithValues(from config: Config) {
        guidingFocalLength = config.guidingFocalLength
        guidingPixelSize = config.guidingPixelSize
        imagingFocalLength = config.imagingFocalLength
        imagingPixelSize = config.imagingPixelSize
        maxPixelShift = config.maxPixelShift
        name = config.name
        scale = config.scale
    }
}
