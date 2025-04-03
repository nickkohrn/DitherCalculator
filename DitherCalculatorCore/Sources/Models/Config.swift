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

    public var _guidingFocalLength: Int?
    public var _guidingPixelSize: Double?
    public var _imagingFocalLength: Int?
    public var _imagingPixelSize: Double?
    public var maxPixelShift: Int?
    public var name: String?
    public let recordID: CKRecord.ID
    public var scale: Double?

    public var guidingFocalLength: FocalLength? {
        guard let _guidingFocalLength else { return nil }
        return FocalLength(value: _guidingFocalLength)
    }

    public var guidingPixelSize: PixelSize? {
        guard let _guidingPixelSize else { return nil }
        return PixelSize(value: _guidingPixelSize)
    }

    public var imagingFocalLength: FocalLength? {
        guard let _imagingFocalLength else { return nil }
        return FocalLength(value: _imagingFocalLength)
    }

    public var imagingPixelSize: PixelSize? {
        guard let _imagingPixelSize else { return nil }
        return PixelSize(value: _imagingPixelSize)
    }

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
        self._guidingFocalLength = guidingFocalLength
        self._guidingPixelSize = guidingPixelSize
        self._imagingFocalLength = imagingFocalLength
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
        let record = CKRecord(recordType: Config.Key.type.rawValue, recordID: recordID)
        record[Config.Key.guidingFocalLength.rawValue] = _guidingFocalLength
        record[Config.Key.guidingPixelSize.rawValue] = _guidingPixelSize
        record[Config.Key.imagingFocalLength.rawValue] = _imagingFocalLength
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
