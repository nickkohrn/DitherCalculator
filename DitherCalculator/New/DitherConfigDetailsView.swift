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
    private let cloudService: any CloudSyncService
    public var config: DitherConfig?
    public var isShowingDeleteConfirmation = false
    public var shouldDismiss = false
    public var isDeleting = false
    public let didDeleteConfig: (CKRecord.ID) -> Void

    public init(
        cloudService: any CloudSyncService,
        config: DitherConfig? = nil,
        didDeleteConfig: @escaping (CKRecord.ID) -> Void
    ) {
        self.cloudService = cloudService
        self.config = config
        self.didDeleteConfig = didDeleteConfig
    }

    public func result() -> Int {
        guard let config else { return 0 }
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
        return result ?? 0
    }

    public func tappedDeleteButton() {
        isShowingDeleteConfirmation = true
    }

    public func tappedDeleteConfirmationCancel() {
        isShowingDeleteConfirmation = false
    }

    public func tappedDeleteConfirmationConfirm() {
        guard let config else { return }
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

    public func tappedEditButton() {}
}

public struct DitherConfigDetailsView: View {
    @Environment(\.ditherConfig) private var ditherConfig
    @Environment(\.dismiss) private var dismiss
    @Bindable private var viewModel: DitherConfigDetailsViewModel

    public init(viewModel: DitherConfigDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            if let config = viewModel.config {
                List {
                    Section {
                        LabeledContent("Name", value: config.name)
                    }
                    Section {
                        LabeledContent("Focal Length", value: config.imagingFocalLengthMeasurement.formatted(.measurement(width: .abbreviated, usage: .asProvided)))
                        LabeledContent("Pixel Size", value: config.imagingPixelSizeMeasurement.formatted(.measurement(width: .abbreviated, usage: .asProvided)))
                    } header: {
                        ImagingSectionHeader()
                    }
                    Section {
                        LabeledContent("Focal Length", value: config.guidingFocalLengthMeasurement.formatted(.measurement(width: .abbreviated, usage: .asProvided)))
                        LabeledContent("Pixel Size", value: config.guidingPixelSizeMeasurement.formatted(.measurement(width: .abbreviated, usage: .asProvided)))
                    } header: {
                        GuidingSectionHeader()
                    }
                    Section {
                        LabeledContent("Scale", value: config.scale.formatted())
                        LabeledContent("Max Shift") {
                            Text("^[\(config.maxPixelShift) pixel](inflect: true)")
                        }
                    } header: {
                        ControlSectionHeader()
                    }
                    Section {
                        LabeledContent("Result") {
                            Text("^[\(viewModel.result()) pixel](inflect: true)")
                        }
                    }
                }
            } else {
                DitherConfigUnavailableView()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton { dismiss() }
            }
            if viewModel.config != nil {
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
                didDeleteConfig: { _ in }
            )
        )
        .environment(\.ditherConfig, DitherConfig(
            imagingFocalLength: 382,
            imagingPixelSize: 3.76,
            guidingFocalLength: 200,
            guidingPixelSize: 2.99,
            scale: 1,
            maxPixelShift: 10,
            name: "Starfront Rig",
            recordID: CKRecord.ID(recordName: UUID().uuidString)
        ))
    }
}

#Preview("Unavailable") {
    NavigationStack {
        DitherConfigDetailsView(
            viewModel: DitherConfigDetailsViewModel(
                cloudService: MockCloudSyncService(
                    accountStatus: .success(.available),
                    delete: .success(CKRecord.ID(recordName: UUID().uuidString))
                ),
                didDeleteConfig: { _ in }
            )
        )
    }
}
