//
//  SaveConfigViewModel.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Models
import Observation
import Syncing

@MainActor
@Observable
public final class SaveConfigViewModel {
    public var isSaving = false
    public var name = ""
    public var shouldDismiss = false

    public var disableSave: Bool {
        trimmedName.isEmpty
    }

    public var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func result(for config: Config) -> DitherResult? {
        try? ConfigCalculator.result(for: config)
    }

    public init() {}

    public func tappedSaveButton(
        for config: Config,
        syncService: any SyncService
    ) async {
        isSaving = true
        config.name = trimmedName.isEmpty ? nil : trimmedName
        let record = config.newCKRecord()
        do {
            _ = try await syncService.save(record)
            await MainActor.run {
                shouldDismiss = true
            }
        } catch {
            print(error)
            await MainActor.run {
                isSaving = false
            }
        }
    }
}
