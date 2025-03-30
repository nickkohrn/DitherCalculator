//
//  DitherConfig.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Foundation
import SwiftUI

public struct DitherConfig {
    public let imagingFocalLength: Double
    public let imagingPixelSize: Double
    public let guidingFocalLength: Double
    public let guidingPixelSize: Double
    public let scale: Double
    public let maxPixelShift: Int
    public var name: String
    public let recordID: CKRecord.ID

    public init(
        imagingFocalLength: Double,
        imagingPixelSize: Double,
        guidingFocalLength: Double,
        guidingPixelSize: Double,
        scale: Double,
        maxPixelShift: Int,
        name: String,
        recordID: CKRecord.ID
    ) {
        self.imagingFocalLength = imagingFocalLength
        self.imagingPixelSize = imagingPixelSize
        self.guidingFocalLength = guidingFocalLength
        self.guidingPixelSize = guidingPixelSize
        self.scale = scale
        self.maxPixelShift = maxPixelShift
        self.name = name
        self.recordID = recordID
    }

    public enum Key: String {
        case type = "DitherConfig"
        case imagingFocalLength
        case imagingPixelSize
        case guidingFocalLength
        case guidingPixelSize
        case scale
        case maxPixelShift
        case name
    }
}

extension DitherConfig {
    public var imagingFocalLengthMeasurement: Measurement<UnitLength> {
        .init(value: imagingFocalLength, unit: .millimeters)
    }

    public var imagingPixelSizeMeasurement: Measurement<UnitLength> {
        .init(value: imagingPixelSize, unit: .micrometers)
    }

    public var guidingFocalLengthMeasurement: Measurement<UnitLength> {
        .init(value: guidingFocalLength, unit: .millimeters)
    }

    public var guidingPixelSizeMeasurement: Measurement<UnitLength> {
        .init(value: guidingPixelSize, unit: .micrometers)
    }
}

extension DitherConfig: Identifiable {
    public var id: CKRecord.ID { recordID }
}

extension DitherConfig {
    public init?(from record: CKRecord) {
        guard
            let imagingFocalLength = record[DitherConfig.Key.imagingFocalLength.rawValue] as? Double,
            let imagingPixelSize = record[DitherConfig.Key.imagingPixelSize.rawValue] as? Double,
            let guidingFocalLength = record[DitherConfig.Key.guidingFocalLength.rawValue] as? Double,
            let guidingPixelSize = record[DitherConfig.Key.guidingPixelSize.rawValue] as? Double,
            let scale = record[DitherConfig.Key.scale.rawValue] as? Double,
            let maxPixelShift = record[DitherConfig.Key.maxPixelShift.rawValue] as? Int,
            let name = record[DitherConfig.Key.name.rawValue] as? String
        else { return nil }
        self = DitherConfig(
            imagingFocalLength: imagingFocalLength,
            imagingPixelSize: imagingPixelSize,
            guidingFocalLength: guidingFocalLength,
            guidingPixelSize: guidingPixelSize,
            scale: scale,
            maxPixelShift: maxPixelShift,
            name: name,
            recordID: record.recordID
        )
    }

    public func newCKRecord() -> CKRecord {
        let record = CKRecord(recordType: DitherConfig.Key.type.rawValue)
        record[DitherConfig.Key.imagingFocalLength.rawValue] = imagingFocalLength
        record[DitherConfig.Key.imagingPixelSize.rawValue] = imagingPixelSize
        record[DitherConfig.Key.guidingFocalLength.rawValue] = guidingFocalLength
        record[DitherConfig.Key.guidingPixelSize.rawValue] = guidingPixelSize
        record[DitherConfig.Key.scale.rawValue] = scale
        record[DitherConfig.Key.maxPixelShift.rawValue] = maxPixelShift
        record[DitherConfig.Key.name.rawValue] = name
        return record
    }
}

extension EnvironmentValues {
    @Entry public var ditherConfig: DitherConfig?
}
