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
        case imagingFocalLength
        case imagingPixelSize
        case type = "Config"
    }

    public var guidingFocalLength: Int?
    public var imagingFocalLength: Int?
    public var imagingPixelSize: Double?
    public let recordID: CKRecord.ID

    public init(
        guidingFocalLength: Int?,
        imagingFocalLength: Int?,
        imagingPixelSize: Double?,
        recordID: CKRecord.ID
    ) {
        self.imagingFocalLength = imagingFocalLength
        self.imagingPixelSize = imagingPixelSize
        self.recordID = recordID
    }
}

extension Config: Identifiable {
    public var id: CKRecord.ID { recordID }
}

extension Config {
    public convenience init?(from record: CKRecord) {
        self.init(
            guidingFocalLength: record[Config.Key.guidingFocalLength.rawValue] as? Int,
            imagingFocalLength: record[Config.Key.imagingFocalLength.rawValue] as? Int,
            imagingPixelSize: record[Config.Key.imagingPixelSize.rawValue] as? Double,
            recordID: record.recordID
        )
    }

    public func newCKRecord() -> CKRecord {
        let record = CKRecord(recordType: Config.Key.type.rawValue)
        record[Config.Key.guidingFocalLength.rawValue] = guidingFocalLength
        record[Config.Key.imagingFocalLength.rawValue] = imagingFocalLength
        record[Config.Key.imagingPixelSize.rawValue] = imagingPixelSize
        return record
    }
}

extension Config {
    func updateWithValues(from config: Config) {
        guidingFocalLength = config.guidingFocalLength
        imagingFocalLength = config.imagingFocalLength
        imagingPixelSize = config.imagingPixelSize
    }
}
