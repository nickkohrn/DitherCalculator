//
//  SavedDitherConfigRowView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor @Observable
public final class SavedDitherConfigRowViewModel {
    public let config: DitherConfig

    public func result() -> DitherResult? {
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

    public init(config: DitherConfig) {
        self.config = config
    }
}

public struct SavedDitherConfigRowView: View {
    private let viewModel: SavedDitherConfigRowViewModel

    public init(viewModel: SavedDitherConfigRowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        LabeledContent(viewModel.config.name) {
            DitherResultText(result: viewModel.result())
        }
    }
}

#Preview {
    SavedDitherConfigRowView(
        viewModel: SavedDitherConfigRowViewModel(
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
