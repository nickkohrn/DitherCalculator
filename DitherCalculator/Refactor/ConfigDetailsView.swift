//
//  ConfigDetailsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor @Observable
final class ConfigDetailsViewModel {
    public var isShowingEditView = false

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

    func tappedEditButton() {
        isShowingEditView = true
    }
}

struct ConfigDetailsView: View {
    @Environment(Config.self) private var config
    @State private var viewModel = ConfigDetailsViewModel()

    var body: some View {
        List {
            Section {
                LabeledNameRow(name: config.name)
            }
            Section {
                LabeledFocalLengthRow(value: config.imagingFocalLength)
                LabeledPixelSizeRow(value: config.imagingPixelSize)
            } header: {
                ImagingSectionHeader()
            }
            Section {
                LabeledFocalLengthRow(value: config.guidingFocalLength)
                LabeledPixelSizeRow(value: config.guidingPixelSize)
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
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", action: viewModel.tappedEditButton)
            }
        }
        .sheet(isPresented: $viewModel.isShowingEditView) {
            NavigationStack {
                ConfigEditView()
                    .environment(config)
            }
        }
    }
}

#Preview {
    ConfigDetailsView()
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
