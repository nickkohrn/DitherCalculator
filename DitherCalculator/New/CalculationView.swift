//
//  CalculationView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import Observation
import SwiftUI

@MainActor @Observable
public final class CalculationViewModel {
    public var imagingFocalLength: Double?
    public var imagingPixelSize: Double?
    public var guidingFocalLength: Double?
    public var guidingPixelSize: Double?
    public var scale: Double?
    public var maxPixelShift: Int?
    public var selectedComponent: CalculationComponent?
    public var isShowingSaveView = false

    public func result() -> Int {
        guard
            let imagingFocalLength,
            let imagingPixelSize,
            let guidingFocalLength,
            let guidingPixelSize,
            let scale,
            let maxPixelShift
        else { return 0 }
        let result = try? DitherCalculator.calculateDitherPixels(with: DitherParameters(
            imagingMetadata: EquipmentMetadata(
                focalLength: imagingFocalLength,
                pixelSize: imagingPixelSize
            ),
            guidingMetadata: EquipmentMetadata(
                focalLength: guidingFocalLength,
                pixelSize: guidingPixelSize
            ),
            desiredImagingShiftPixels: maxPixelShift,
            scale: scale
        ))
        return result ?? 0
    }

    public init() {}

    public func tappedSaveButton() {
        isShowingSaveView = true
    }
}

public struct CalculationView: View {
    @Bindable private var viewModel: CalculationViewModel

    public init(viewModel: CalculationViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section {
                LabeledContent("Result") {
                    Text("^[\(viewModel.result()) pixel](inflect: true)")
                }
            }
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Button {
                            viewModel.selectedComponent = .imagingFocalLength
                        } label: {
                            FocalLengthRowHeader()
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        .learnWhatThisIsAccessibilityHint()
                        TextField(0.formatted(), value: $viewModel.imagingFocalLength, format: .number)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                HStack {
                    VStack(alignment: .leading) {
                        Button {
                            viewModel.selectedComponent = .imagingPixelSize
                        } label: {
                            PixelSizeRowHeader()
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        .learnWhatThisIsAccessibilityHint()
                        TextField(0.formatted(), value: $viewModel.imagingPixelSize, format: .number)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            } header: {
                ImagingSectionHeader()
            }
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Button {
                            viewModel.selectedComponent = .guidingFocalLength
                        } label: {
                            FocalLengthRowHeader()
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        .learnWhatThisIsAccessibilityHint()
                        TextField(0.formatted(), value: $viewModel.guidingFocalLength, format: .number)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                HStack {
                    VStack(alignment: .leading) {
                        Button {
                            viewModel.selectedComponent = .guidingPixelSize
                        } label: {
                            PixelSizeRowHeader()
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        .learnWhatThisIsAccessibilityHint()
                        TextField(0.formatted(), value: $viewModel.guidingPixelSize, format: .number)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            } header: {
                GuidingSectionHeader()
            }
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Button {
                            viewModel.selectedComponent = .scale
                        } label: {
                            ScaleRowHeader()
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        .learnWhatThisIsAccessibilityHint()
                        TextField(1.formatted(), value: $viewModel.scale, format: .number)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                HStack {
                    VStack(alignment: .leading) {
                        Button {
                            viewModel.selectedComponent = .pixelShift
                        } label: {
                            MaxPixelShiftRowHeader()
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        .maxShiftInPixelsAccessibilityLabel()
                        .learnWhatThisIsAccessibilityHint()
                        TextField(0.formatted(), value: $viewModel.maxPixelShift, format: .number)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            } header: {
                ControlSectionHeader()
            }
        }
        .navigationTitle("Calulate Dither Amount")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                SaveButton { viewModel.tappedSaveButton() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CalculationView(viewModel: CalculationViewModel())
    }
}
