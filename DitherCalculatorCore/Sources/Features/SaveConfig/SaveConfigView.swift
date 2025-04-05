//
//  SaveConfigView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CoreUI
import Models
import SwiftUI
import Syncing

public struct SaveConfigView: View {
    @Environment(Config.self) private var config
    @Environment(CloudService.self) private var cloudService
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SaveConfigViewModel()

    public init() {}

    public var body: some View {
        Form {
            Section {
                NameFormRow(value: $viewModel.name)
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
        .navigationTitle("Save")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CancelButton { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    SaveButton {
                        Task {
                            await viewModel.tappedSaveButton(
                                for: config,
                                syncService: cloudService
                            )
                        }
                    }
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

#if DEBUG
import CloudKit

#Preview {
    NavigationStack {
        SaveConfigView()
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
}
#endif
