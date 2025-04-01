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

    public func result(for config: Config) -> Int? {
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
                nameRow
            }
            Section {
                imagingFocalLengthRow
                imagingPixelSizeRow
            } header: {
                ImagingSectionHeader()
            }
            Section {
                guidingFocalLengthRow
                guidingPixelSizeRow
            } header: {
                GuidingSectionHeader()
            }
            Section {
                scaleRow
                maxPixelShiftRow
            } header: {
                ControlSectionHeader()
            }
            Section {
                ResultRow(result: viewModel.result(for: config))
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CancelButton { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Button("Save") { viewModel.tappedSaveButton(for: config) }
                }
            }
        }
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue { dismiss() }
        }
        .disabled(viewModel.isSaving)
    }

    private var nameRow: some View {
        TextField("Name", text: $viewModel.name)
    }

    @ViewBuilder
    private var imagingFocalLengthRow: some View {
        LabeledContent("Focal Length") {
            if let value = config.imagingFocalLength {
                Text(value.formatted())
            } else {
                MissingValuePlaceholder()
            }
        }
    }

    @ViewBuilder
    private var imagingPixelSizeRow: some View {
        LabeledContent("Pixel Size") {
            if let value = config.imagingPixelSize {
                Text(value.formatted())
            } else {
                MissingValuePlaceholder()
            }
        }
    }

    @ViewBuilder
    private var guidingFocalLengthRow: some View {
        LabeledContent("Focal Length") {
            if let value = config.guidingFocalLength {
                Text(value.formatted())
            } else {
                MissingValuePlaceholder()
            }
        }
    }

    @ViewBuilder
    private var guidingPixelSizeRow: some View {
        LabeledContent("Pixel Size") {
            if let value = config.guidingPixelSize {
                Text(value.formatted())
            } else {
                MissingValuePlaceholder()
            }
        }
    }

    @ViewBuilder
    private var scaleRow: some View {
        LabeledContent("Scale") {
            if let value = config.scale {
                Text(value.formatted())
            } else {
                MissingValuePlaceholder()
            }
        }
    }

    @ViewBuilder
    private var maxPixelShiftRow: some View {
        LabeledContent("Max Pixel Shift") {
            if let value = config.maxPixelShift {
                Text(value.formatted())
            } else {
                MissingValuePlaceholder()
            }
        }
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
                    recordID: CKRecord.ID(recordName: UUID().uuidString),
                    scale: 1
                )
            )
    }
}
