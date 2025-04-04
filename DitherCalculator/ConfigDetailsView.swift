//
//  ConfigDetailsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import CloudKit
import CoreUI
import Models
import Observation
import SwiftUI

@MainActor @Observable
final class ConfigDetailsViewModel {
    public var isDeleting = false
    public var isShowingDeleteConfirmationDialog = false
    public var isShowingEditView = false
    private let didDeleteConfig: (Config) -> Void
    var shouldDismiss = false

    init(didDeleteConfig: @escaping (Config) -> Void) {
        self.didDeleteConfig = didDeleteConfig
    }

    public func result(for config: Config) -> DitherResult? {
        try? ConfigCalculator.result(for: config)
    }

    func tappedDeleteButton() {
        isShowingDeleteConfirmationDialog = true
    }

    func tappedDeleteConfirmationCancel() {
        isDeleting = false
        isShowingDeleteConfirmationDialog = false
    }

    func tappedDeleteConfirmationConfirm(for config: Config) {
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

    func tappedEditButton() {
        isShowingEditView = true
    }
}

struct ConfigDetailsView: View {
    @Environment(Config.self) private var config
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ConfigDetailsViewModel

    init(viewModel: ConfigDetailsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                LabeledNameRow(name: config.name)
            }
            Section {
                LabeledFocalLengthRow(value: config.imagingFocalLength.measurement)
                LabeledPixelSizeRow(value: config.imagingPixelSize.measurement)
            } header: {
                ImagingSectionHeader()
            }
            Section {
                LabeledFocalLengthRow(value: config.guidingFocalLength.measurement)
                LabeledPixelSizeRow(value: config.guidingPixelSize.measurement)
            } header: {
                GuidingSectionHeader()
            }
            Section {
                LabeledScaleRow(value: config.scale)
                LabeledMaxPixelShiftRow(value: config.maxPixelShift)
            } header: {
                ControlSectionHeader()
            }
            Section {
                LabeledResultRow(result: viewModel.result(for: config))
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DeleteButton { viewModel.tappedDeleteButton() }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", action: viewModel.tappedEditButton)
            }
        }
        .confirmationDialog(
            "Delete Config",
            isPresented: $viewModel.isShowingDeleteConfirmationDialog,
            titleVisibility: .visible,
            actions: {
                CancelButton { viewModel.tappedDeleteConfirmationCancel() }
                DeleteButton { viewModel.tappedDeleteConfirmationConfirm(for: config) }
            },
            message: {
                Text("Are you sure you want to delete this config? This cannot be undone.")
            }
        )
        .sheet(isPresented: $viewModel.isShowingEditView) {
            NavigationStack {
                ConfigEditView()
                    .environment(config)
            }
        }
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue { dismiss() }
        }
        .disabled(viewModel.isDeleting)
    }
}

#Preview {
    ConfigDetailsView(viewModel: ConfigDetailsViewModel(didDeleteConfig: {_ in }))
        .environment(
            Config(
                guidingFocalLength: FocalLength(value: 200),
                guidingPixelSize: PixelSize(value: 2.99),
                imagingFocalLength: FocalLength(value: 382),
                imagingPixelSize: PixelSize(value: 3.76),
                maxPixelShift: 10,
                name: "Starfront Rig",
                recordID: CKRecord.ID(recordName: UUID().uuidString),
                scale: 1
            )
        )
}
