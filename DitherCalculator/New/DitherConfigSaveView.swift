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
    public var config: DitherConfig
    public var isSaving = false

    public init(config: DitherConfig) {
        self.config = config
    }

    public func result() -> Int {
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

    public func tappedCancelButton() {}

    public func tappedSaveButton() {}
}

public struct DitherConfigSaveView: View {
    @Environment(\.dismiss) private var dismiss
    private let viewModel: DitherConfigSaveViewModel

    public init(viewModel: DitherConfigSaveViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            Section {
                LabeledContent("Name", value: viewModel.config.name)
                LabeledContent("Result") {
                    Text("^[\(viewModel.result()) pixel](inflect: true)")
                }
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
        }
        .navigationTitle("New Config")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CancelButton { viewModel.tappedCancelButton() }
            }
            ToolbarItem(placement: .confirmationAction) {
                SaveButton { viewModel.tappedSaveButton() }
            }
        }
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
                    name: "Starfront Rig",
                    recordID: CKRecord.ID(recordName: UUID().uuidString)
                )
            )
        )
    }
}

