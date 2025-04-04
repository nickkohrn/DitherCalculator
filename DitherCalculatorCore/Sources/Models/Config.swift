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

    public var guidingFocalLength = FocalLength(value: nil)
    public var _guidingPixelSize: Double?
    public var imagingFocalLength = FocalLength(value: nil)
    public var _imagingPixelSize: Double?
    public var maxPixelShift: Int?
    public var name: String?
    public let recordID: CKRecord.ID
    public var scale: Double?

    public var guidingPixelSize: PixelSize? {
        guard let _guidingPixelSize else { return nil }
        return PixelSize(value: _guidingPixelSize)
    }

    public var imagingPixelSize: PixelSize? {
        guard let _imagingPixelSize else { return nil }
        return PixelSize(value: _imagingPixelSize)
    }

    public init(
        guidingFocalLength: FocalLength,
        guidingPixelSize: Double?,
        imagingFocalLength: FocalLength,
        imagingPixelSize: Double?,
        maxPixelShift: Int?,
        name: String?,
        recordID: CKRecord.ID,
        scale: Double?
    ) {
        self.guidingFocalLength = guidingFocalLength
        self._guidingPixelSize = guidingPixelSize
        self.imagingFocalLength = imagingFocalLength
        self._imagingPixelSize = imagingPixelSize
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
            guidingPixelSize: record[Config.Key.guidingPixelSize.rawValue] as? Double,
            imagingFocalLength: FocalLength(value: record[Config.Key.imagingFocalLength.rawValue] as? Int),
            imagingPixelSize: record[Config.Key.imagingPixelSize.rawValue] as? Double,
            maxPixelShift: record[Config.Key.maxPixelShift.rawValue] as? Int,
            name: record[Config.Key.name.rawValue] as? String,
            recordID: record.recordID,
            scale: record[Config.Key.scale.rawValue] as? Double
        )
    }

    public func newCKRecord() -> CKRecord {
        let record = CKRecord(recordType: Config.Key.type.rawValue, recordID: recordID)
        record[Config.Key.guidingFocalLength.rawValue] = guidingFocalLength.value
        record[Config.Key.guidingPixelSize.rawValue] = _guidingPixelSize
        record[Config.Key.imagingFocalLength.rawValue] = imagingFocalLength.value
        record[Config.Key.imagingPixelSize.rawValue] = _imagingPixelSize
        record[Config.Key.maxPixelShift.rawValue] = maxPixelShift
        record[Config.Key.name.rawValue] = name
        record[Config.Key.scale.rawValue] = scale
        return record
    }
}

extension Config {
    public func updateWithValues(from config: Config) {
        _guidingFocalLength = config._guidingFocalLength
        _guidingPixelSize = config._guidingPixelSize
        _imagingFocalLength = config._imagingFocalLength
        _imagingPixelSize = config._imagingPixelSize
        maxPixelShift = config.maxPixelShift
        name = config.name
        scale = config.scale
    }
}
