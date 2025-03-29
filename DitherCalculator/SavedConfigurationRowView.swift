//
//  SavedConfigurationRowView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//

import Observation
import SwiftUI

@MainActor
@Observable
public final class SavedConfigurationRowViewModel {
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

public struct SavedConfigurationRowView: View {
    private let viewModel: SavedConfigurationRowViewModel

    public init(viewModel: SavedConfigurationRowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        LabeledContent(viewModel.configuration.name) {
            Text(viewModel.formattedResult)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    SavedConfigurationRowView(
        viewModel: SavedConfigurationRowViewModel(
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
