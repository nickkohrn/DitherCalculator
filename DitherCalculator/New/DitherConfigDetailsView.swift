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
    public var config: DitherConfig?

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

    public func onAppear(with config: DitherConfig?) {
        self.config = config
    }

    public func tappedDeleteButton() {}

    public func tappedEditButton() {}
}

public struct DitherConfigDetailsView: View {
    @Environment(\.ditherConfig) private var ditherConfig
    @Environment(\.dismiss) private var dismiss
    private let viewModel: DitherConfigDetailsViewModel

    public init(viewModel: DitherConfigDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            if let config = viewModel.config {
                List {
                    Section {
                        LabeledContent("Name", value: config.name)
                        LabeledContent("Result") {
                            Text("^[\(viewModel.result()) pixel](inflect: true)")
                        }
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
                }
            } else {
                ContentUnavailableView("Configuration Unavailable", systemImage: "document.badge.gearshape")
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
                    DeleteButton(action: viewModel.tappedDeleteButton)
                }
            }
        }
        .onAppear {
            viewModel.onAppear(with: ditherConfig)
        }
    }
}

#Preview("Available") {
    NavigationStack {
        DitherConfigDetailsView(viewModel: DitherConfigDetailsViewModel())
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
        DitherConfigDetailsView(viewModel: DitherConfigDetailsViewModel())
    }
}
