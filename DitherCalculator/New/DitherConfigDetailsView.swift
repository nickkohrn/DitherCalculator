//
//  DitherConfigDetailsViewModel.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation
import Foundation
import SwiftUI

@MainActor @Observable
public final class DitherConfigDetailsViewModel {
    public let cloudService: any CloudSyncService
    public private(set) var config: DitherConfig
    public var isShowingDeleteConfirmation = false
    public var shouldDismiss = false
    public var isDeleting = false
    public let didDeleteConfig: (CKRecord.ID) -> Void
    public let didEditConfig: (DitherConfig) -> Void
    public var isShowingEditView = false

    public init(
        cloudService: any CloudSyncService,
        config: DitherConfig,
        didDeleteConfig: @escaping (CKRecord.ID) -> Void,
        didEditConfig: @escaping (DitherConfig) -> Void
    ) {
        self.cloudService = cloudService
        self.config = config
        self.didDeleteConfig = didDeleteConfig
        self.didEditConfig = didEditConfig
    }

    public func didEditConfig(config: DitherConfig) {
        self.config = config
        didEditConfig(config)
    }

    public func result() -> DitherResult? {
        let result = try? DitherCalculator.calculateDitherPixels(with: DitherParameters(
            imagingMetadata: EquipmentMetadata(
                focalLength: config.imagingFocalLength,
                pixelSize: config.imagingPixelSize
            ),
            guidingMetadata: EquipmentMetadata(
                focalLength: config.guidingFocalLength,
                pixelSize: config.guidingPixelSize
            ),
            desiredImagingShiftPixels: config.maxPixelShift,
            scale: config.scale
        ))
        return result
    }

    public func tappedDeleteButton() {
        isShowingDeleteConfirmation = true
    }

    public func tappedDeleteConfirmationCancel() {
        isShowingDeleteConfirmation = false
    }

    public func tappedDeleteConfirmationConfirm() {
        isShowingDeleteConfirmation = false
        isDeleting = true
        Task {
            do {
                _ = try await cloudService.deleteRecord(withID: config.recordID)
                await MainActor.run {
                    didDeleteConfig(config.recordID)
                    shouldDismiss = true
                }
            } catch {
                print(error)
            }
        }
    }

    public func tappedEditButton() {
        isShowingEditView = true
    }
}

public struct DitherConfigDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var viewModel: DitherConfigDetailsViewModel

    public init(viewModel: DitherConfigDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            Section {
                LabeledContent("Name", value: viewModel.config.name)
            }
            Section {
                LabeledContent("Focal Length", value: viewModel.config.imagingFocalLengthMeasurement.formatted(.measurement(width: .abbreviated, usage: .asProvided)))
                LabeledContent("Pixel Size", value: viewModel.config.imagingPixelSizeMeasurement.formatted(.measurement(width: .abbreviated, usage: .asProvided)))
            } header: {
                ImagingSectionHeader()
            }
            Section {
                LabeledContent("Focal Length", value: viewModel.config.guidingFocalLengthMeasurement.formatted(.measurement(width: .abbreviated, usage: .asProvided)))
                LabeledContent("Pixel Size", value: viewModel.config.guidingPixelSizeMeasurement.formatted(.measurement(width: .abbreviated, usage: .asProvided)))
            } header: {
                GuidingSectionHeader()
            }
            Section {
                LabeledContent("Scale", value: viewModel.config.scale.formatted())
                LabeledContent("Max Shift") {
                    Text("^[\(viewModel.config.maxPixelShift) pixel](inflect: true)")
                }
            } header: {
                ControlSectionHeader()
            }
            Section {
                LabeledContent("Result") {
                    DitherResultText(result: viewModel.result())
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton { dismiss() }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", action: viewModel.tappedEditButton)
            }
            ToolbarItem(placement: .bottomBar) {
                if viewModel.isDeleting {
                    Button {
                        // no-op
                    } label: {
                        ProgressView()
                    }
                } else {
                    DeleteButton(action: viewModel.tappedDeleteButton)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingEditView) {
            NavigationStack {
                DitherConfigEditView(
                    viewModel: DitherConfigEditViewModel(
                        syncService: viewModel.cloudService,
                        config: viewModel.config,
                        didEditConfig: { config in
                            viewModel.didEditConfig(config: config)
                        }
                    )
                )
            }
        }
        .confirmationDialog(
            "Delete Config",
            isPresented: $viewModel.isShowingDeleteConfirmation,
            titleVisibility: .visible,
            actions: {
                Button("Cancel", role: .cancel, action: viewModel.tappedDeleteConfirmationCancel)
                Button("Delete", role: .destructive, action: viewModel.tappedDeleteConfirmationConfirm)
            },
            message: {
                Text("Are you sure you want to delete this config? This cannot be undone.")
            }
        )
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue { dismiss() }
        }
        .disabled(viewModel.isDeleting)
    }
}

#Preview("Available") {
    NavigationStack {
        DitherConfigDetailsView(
            viewModel: DitherConfigDetailsViewModel(
                cloudService: MockCloudSyncService(
                    accountStatus: .success(.available),
                    delete: .success(CKRecord.ID(recordName: UUID().uuidString))
                ),
                config: DitherConfig(
                    imagingFocalLength: 382,
                    imagingPixelSize: 3.76,
                    guidingFocalLength: 200,
                    guidingPixelSize: 2.99,
                    scale: 1,
                    maxPixelShift: 10,
                    name: "Starfront Rig",
                    recordID: CKRecord.ID(recordName: UUID().uuidString)
                ),
                didDeleteConfig: { _ in },
                didEditConfig: { _ in }
            )
        )
    }
}
