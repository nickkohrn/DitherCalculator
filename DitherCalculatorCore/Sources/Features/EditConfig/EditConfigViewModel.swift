//
//  EditConfigViewModel.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/4/25.
//

import CloudKit
import Models
import Observation
import Syncing

@MainActor
@Observable
public final class EditConfigViewModel {
    private var existingConfig: Config?
    public var guidingFocalLength: Int?
    public var guidingPixelSize: Double?
    public var imagingFocalLength: Int?
    public var imagingPixelSize: Double?
    public var isSaving = false
    public var maxPixelShift: Int?
    public var name = ""
    public var scale: Double?
    public var selectedComponent: ConfigCalculator.Component?
    public var shouldDismiss = false

    public var disableSave: Bool {
        guard let existingConfig,
              let guidingFocalLength,
              let guidingPixelSize,
              let imagingFocalLength,
              let imagingPixelSize,
              let maxPixelShift,
              let scale else {
            return true
        }
        return guidingFocalLength == existingConfig.guidingFocalLength.value
        && guidingPixelSize == existingConfig.guidingPixelSize.measurement.value
        && imagingFocalLength == existingConfig.imagingFocalLength.value
        && imagingPixelSize == existingConfig.imagingPixelSize.measurement.value
        && maxPixelShift == existingConfig.maxPixelShift
        && scale == existingConfig.scale
        && (trimmedName.isEmpty || trimmedName == existingConfigTrimmedName)
    }

    private var existingConfigTrimmedName: String {
        if let name = existingConfig?.name {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public init() {}

    public func onAppear(with config: Config) {
        existingConfig = config
        guidingFocalLength = config.guidingFocalLength.value
        guidingPixelSize = config.guidingPixelSize.measurement.value
        imagingFocalLength = config.imagingFocalLength.value
        imagingPixelSize = config.imagingPixelSize.measurement.value
        maxPixelShift = config.maxPixelShift
        name = config.name ?? ""
        scale = config.scale
    }

    public func result(for config: Config) -> DitherResult? {
        try? ConfigCalculator.result(for: config)
    }

    public func tappedSaveButton(
        for config: Config,
        syncService: any SyncService,
        onSuccess: @escaping (Config) -> Void
    ) async {
        await MainActor.run {
            isSaving = true
        }
        do {
            let record = try await syncService.record(for: config.recordID)
            guard record.recordType == Config.Key.type.rawValue else { return }
            record[Config.Key.guidingFocalLength.rawValue] = guidingFocalLength
            record[Config.Key.guidingPixelSize.rawValue] = guidingPixelSize
            record[Config.Key.imagingFocalLength.rawValue] = imagingFocalLength
            record[Config.Key.imagingPixelSize.rawValue] = imagingPixelSize
            record[Config.Key.maxPixelShift.rawValue] = maxPixelShift
            record[Config.Key.name.rawValue] = trimmedName
            record[Config.Key.scale.rawValue] = scale
            _ = try await syncService.save(record)
            await MainActor.run {
                guard let config = Config(from: record) else {
                    print("Failed to initialize Config from CKRecord")
                    return
                }
                shouldDismiss = true
                onSuccess(config)
            }
        } catch {
            await MainActor.run {
                isSaving = false
                print(error)
            }
        }
    }
}
