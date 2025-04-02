//
//  ConfigDetailsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor @Observable
final class ConfigSaveViewModel {
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
        guard
            let imagingFocalLength = config.imagingFocalLength,
            let imagingPixelSize = config.imagingPixelSize,
            let guidingFocalLength = config.guidingFocalLength,
            let guidingPixelSize = config.guidingPixelSize,
            let scale = config.scale,
            let maxPixelShift = config.maxPixelShift
        else { return nil }
        let result = try? DitherCalculator.calculateDitherPixels(with: DitherParameters(
            imagingMetadata: EquipmentMetadata(
                focalLength: Double(imagingFocalLength),
                pixelSize: imagingPixelSize
            ),
            guidingMetadata: EquipmentMetadata(
                focalLength: Double(guidingFocalLength),
                pixelSize: guidingPixelSize
            ),
            desiredImagingShiftPixels: maxPixelShift,
            scale: scale
        ))
        return result
    }

    init() {}

    func tappedSaveButton(for config: Config) {
        isSaving = true
        config.name = trimmedName.isEmpty ? nil : trimmedName
        let record = config.newCKRecord()
        Task {
            do {
                try await CKContainer.default().privateCloudDatabase.save(record)
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
}

struct ConfigSaveView: View {
    @Environment(Config.self) private var config
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ConfigSaveViewModel()

    var body: some View {
        Form {
            Section {
                NameFormRow(value: $viewModel.name)
            }
            Section {
                LabeledFocalLengthRow(value: config.imagingFocalLengthMeasurement)
                LabeledPixelSizeRow(value: config.imagingPixelSizeMeasurement)
            } header: {
                ImagingSectionHeader()
            }
            Section {
                LabeledFocalLengthRow(value: config.guidingFocalLengthMeasurement)
                LabeledPixelSizeRow(value: config.guidingPixelSizeMeasurement)
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
                    Button("Save") { viewModel.tappedSaveButton(for: config) }
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

#Preview {
    NavigationStack {
        ConfigSaveView()
            .environment(
                Config(
                    guidingFocalLength: 200,
                    guidingPixelSize: 2.99,
                    imagingFocalLength: 382,
                    imagingPixelSize: 3.76,
                    maxPixelShift: 10,
                    name: "Starfront Rig",
                    recordID: CKRecord.ID(recordName: UUID().uuidString),
                    scale: 1
                )
            )
    }
}
