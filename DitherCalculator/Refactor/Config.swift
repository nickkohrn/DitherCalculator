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
        case type = "Config"
        case imagingFocalLength
    }

    public var imagingFocalLength: Int
    public let recordID: CKRecord.ID

    public init(
        imagingFocalLength: Int,
        recordID: CKRecord.ID
    ) {
        self.imagingFocalLength = imagingFocalLength
        self.recordID = recordID
    }
}

extension Config: Identifiable {
    public var id: CKRecord.ID { recordID }
}

extension Config {
    public convenience init?(from record: CKRecord) {
        guard let imagingFocalLength = record[Config.Key.imagingFocalLength.rawValue] as? Int else { return nil }
        self.init(imagingFocalLength: imagingFocalLength, recordID: record.recordID)
    }

    public func newCKRecord() -> CKRecord {
        let record = CKRecord(recordType: Config.Key.type.rawValue)
        record[Config.Key.imagingFocalLength.rawValue] = imagingFocalLength
        return record
    }
}

extension Config {
    func updateWithValues(from config: Config) {
        imagingFocalLength = config.imagingFocalLength
    }
}
