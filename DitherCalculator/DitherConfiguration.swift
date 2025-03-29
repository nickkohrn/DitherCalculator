//
//  File.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//

import CloudKit
import Foundation

public struct DitherConfiguration: Hashable {
    public let imagingFocalLength: Double
    public let imagingPixelSize: Double
    public let guidingFocalLength: Double
    public let guidingPixelSize: Double
    public let scale: Double
    public let maximumPixelShift: Int
    public let name: String
    public let uuidString: String
}

extension DitherConfiguration: Identifiable {
    public var id: UUID { UUID(uuidString: uuidString) ?? UUID() }
}

public enum DitherConfigurationKeys: String {
    case type = "DitherConfiguration"
    case imagingFocalLength
    case imagingPixelSize
    case guidingFocalLength
    case guidingPixelSize
    case scale
    case maximumPixelShift
    case name
    case uuidString
}

extension DitherConfiguration {
    public var record: CKRecord {
        let record = CKRecord(recordType: DitherConfigurationKeys.type.rawValue)
        record[DitherConfigurationKeys.imagingFocalLength.rawValue] = imagingFocalLength
        record[DitherConfigurationKeys.imagingPixelSize.rawValue] = imagingPixelSize
        record[DitherConfigurationKeys.guidingFocalLength.rawValue] = guidingFocalLength
        record[DitherConfigurationKeys.guidingPixelSize.rawValue] = guidingPixelSize
        record[DitherConfigurationKeys.scale.rawValue] = scale
        record[DitherConfigurationKeys.maximumPixelShift.rawValue] = maximumPixelShift
        record[DitherConfigurationKeys.name.rawValue] = name
        record[DitherConfigurationKeys.uuidString.rawValue] = uuidString
        return record
    }

    init?(from record: CKRecord) {
        guard
            let imagingFocalLength = record[DitherConfigurationKeys.imagingFocalLength.rawValue] as? Double,
            let imagingPixelSize = record[DitherConfigurationKeys.imagingPixelSize.rawValue] as? Double,
            let guidingFocalLength = record[DitherConfigurationKeys.guidingFocalLength.rawValue] as? Double,
            let guidingPixelSize = record[DitherConfigurationKeys.guidingPixelSize.rawValue] as? Double,
            let scale = record[DitherConfigurationKeys.imagingFocalLength.rawValue] as? Double,
            let maximumPixelShift = record[DitherConfigurationKeys.maximumPixelShift.rawValue] as? Int,
            let name = record[DitherConfigurationKeys.name.rawValue] as? String,
            let uuidString = record[DitherConfigurationKeys.uuidString.rawValue] as? String
        else { return nil }
        self = DitherConfiguration(
            imagingFocalLength: imagingFocalLength,
            imagingPixelSize: imagingPixelSize,
            guidingFocalLength: guidingFocalLength,
            guidingPixelSize: guidingPixelSize,
            scale: scale,
            maximumPixelShift: maximumPixelShift,
            name: name,
            uuidString: uuidString
        )
    }
}
