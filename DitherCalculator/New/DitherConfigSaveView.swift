//
//  DitherConfigSaveView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation
import Foundation
import SwiftUI

@MainActor @Observable
public final class DitherConfigSaveViewModel {
    private let cloudSyncService: CloudSyncService
    public var config: DitherConfig
    public var name: String
    public var isSaving = false
    public var shouldDismiss = false

    public var disableSave: Bool {
        result() == nil || trimmedName.isEmpty
    }

    public var formattedResult: LocalizedStringResource {
        "^[\(result() ?? 0) pixel](inflect: true)"
    }

    public var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    public init(config: DitherConfig, cloudSyncService: any CloudSyncService) {
        self.config = config
        self.cloudSyncService = cloudSyncService
        name = config.name
    }

    public func result() -> Int? {
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

    public func tappedSaveButton() {
        isSaving = true
        config.name = trimmedName
        Task {
            try await cloudSyncService.save(config.newCKRecord())
            await MainActor.run {
                shouldDismiss = true
            }
        }
    }
}

public struct DitherConfigSaveView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var viewModel: DitherConfigSaveViewModel

    public init(viewModel: DitherConfigSaveViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section {
                TextField("Name", text: $viewModel.name, axis: .vertical)
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
                    Text(viewModel.formattedResult)
                }
            }
        }
        .navigationTitle("New Config")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CancelButton { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    SaveButton { viewModel.tappedSaveButton() }
                        .disabled(viewModel.disableSave)
                }
            }
        }
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue { dismiss() }
        }
        .disabled(viewModel.isSaving)
    }
}

#Preview("Available") {
    NavigationStack {
        DitherConfigSaveView(
            viewModel: DitherConfigSaveViewModel(
                config: DitherConfig(
                    imagingFocalLength: 382,
                    imagingPixelSize: 3.76,
                    guidingFocalLength: 200,
                    guidingPixelSize: 2.99,
                    scale: 1,
                    maxPixelShift: 10,
                    name: "",
                    recordID: CKRecord.ID(recordName: UUID().uuidString)
                ),
                cloudSyncService: MockCloudSyncService(
                    accountStatus: .success(.available),
                    save: .success(())
                )
            )
        )
    }
}

