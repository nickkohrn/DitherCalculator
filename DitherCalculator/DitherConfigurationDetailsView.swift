//
//  DitherConfigurationDetailsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//

import Observation
import SwiftUI

@MainActor
@Observable
public final class DitherConfigurationDetailsViewModel {
    public let configuration: DitherConfiguration

    private var result: Int? {
        try? DitherCalculator.calculateDitherPixels(with: DitherParameters(
            imagingMetadata: EquipmentMetadata(
                focalLength: configuration.imagingFocalLength,
                pixelSize: configuration.imagingPixelSize
            ),
            guidingMetadata: EquipmentMetadata(
                focalLength: configuration.guidingFocalLength,
                pixelSize: configuration.guidingPixelSize
            ),
            desiredImagingShiftPixels: configuration.maximumPixelShift,
            scale: configuration.scale
        ))
    }

    public var formattedResult: LocalizedStringResource {
        if let result = result {
            return "^[\(result) pixel](inflect: true)"
        } else {
            return "--"
        }
    }

    public init(configuration: DitherConfiguration) {
        self.configuration = configuration
    }
}

public struct DitherConfigurationDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    private let viewModel: DitherConfigurationDetailsViewModel

    public init(viewModel: DitherConfigurationDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            Section {
                LabeledContent("Focal Length") {
                    Text(viewModel.configuration.imagingFocalLengthMeasurement.formatted(.measurement(width: .abbreviated, usage: .asProvided)))
                }
                LabeledContent("Pixel Size") {
                    Text(viewModel.configuration.imagingPixelSizeMeasurement.formatted(.measurement(width: .abbreviated, usage: .asProvided)))
                }
            } header: {
                ImagingSectionHeader()
            }
            Section {
                LabeledContent("Focal Length") {
                    Text(viewModel.configuration.guidingFocalLengthMeasurement.formatted(.measurement(width: .abbreviated, usage: .asProvided)))
                }
                LabeledContent("Pixel Size") {
                    Text(viewModel.configuration.guidingPixelSizeMeasurement.formatted(.measurement(width: .abbreviated, usage: .asProvided)))
                }
            } header: {
                GuidingSectionHeader()
            }
            Section {
                LabeledContent("Scale") {
                    Text(viewModel.configuration.scale.formatted())
                }
                LabeledContent("Pixel Shift") {
                    Text("^[\(viewModel.configuration.maximumPixelShift) pixel](inflect: true)")
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
        .navigationTitle(viewModel.configuration.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton { dismiss() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DitherConfigurationDetailsView(
            viewModel: DitherConfigurationDetailsViewModel(
                configuration: DitherConfiguration(
                    imagingFocalLength: 382,
                    imagingPixelSize: 3.76,
                    guidingFocalLength: 200,
                    guidingPixelSize: 2.99,
                    scale: 1,
                    maximumPixelShift: 10,
                    name: "Starfront Rig",
                    uuidString: UUID().uuidString
                )
            )
        )
    }
}
