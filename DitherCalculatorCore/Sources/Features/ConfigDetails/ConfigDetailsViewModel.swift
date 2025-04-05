//
//  ConfigDetailsViewModel.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/5/25.
//

import CloudKit
import Models
import Observation
import SwiftUI
import Syncing

@MainActor
@Observable
public final class ConfigDetailsViewModel {
    public private(set) var isDeleting = false
    public var isShowingDeleteConfirmationDialog = false
    public var isShowingEditView = false
    private let didDeleteConfig: (Config) -> Void
    public private(set) var shouldDismiss = false

    public init(didDeleteConfig: @escaping (Config) -> Void) {
        self.didDeleteConfig = didDeleteConfig
    }

    public func result(for config: Config) -> DitherResult? {
        try? ConfigCalculator.result(for: config)
    }

    public func tappedDeleteButton() {
        isShowingDeleteConfirmationDialog = true
    }

    public func tappedDeleteConfirmationCancelButton() {
        isDeleting = false
        isShowingDeleteConfirmationDialog = false
    }

    public func tappedDeleteConfirmationConfirm(for config: Config) {
        isDeleting = true
        isShowingDeleteConfirmationDialog = false
        Task {
            do {
                try await CKContainer.default().privateCloudDatabase.deleteRecord(withID: config.recordID)
                await MainActor.run {
                    didDeleteConfig(config)
                    shouldDismiss = true
                }
            } catch {
                print(error)
                await MainActor.run {
                    isDeleting = true
                }
            }
        }
    }

    public func tappedEditButton() {
        isShowingEditView = true
    }
}
