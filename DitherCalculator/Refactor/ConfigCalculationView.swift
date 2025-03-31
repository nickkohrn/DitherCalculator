//
//  ConfigCalculationView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor @Observable
final class ConfigCalculationViewModel {
    var configToSave: Config?
    var guidingFocalLength: Int?
    var guidingPixelSize: Double?
    var imagingFocalLength: Int?
    var imagingPixelSize: Double?
    var isShowingSavedConfigsView = false
    var maxPixelShift: Int?
    var scale: Double?
    var selectedComponent: CalculationComponent?

    var disableSave: Bool {
        result() == nil
    }

    func result() -> Int? {
        guard let guidingFocalLength,
              let guidingPixelSize,
              let imagingFocalLength,
              let imagingPixelSize,
              let maxPixelShift,
              let scale else {
            return nil
        }
        let parameters = DitherParameters(
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
        )
        return try? DitherCalculator.calculateDitherPixels(with: parameters)
    }

    func tappedSaveButton() {
        configToSave = Config(
            guidingFocalLength: guidingFocalLength,
            guidingPixelSize: guidingPixelSize,
            imagingFocalLength: imagingFocalLength,
            imagingPixelSize: imagingPixelSize,
            maxPixelShift: maxPixelShift,
            recordID: CKRecord.ID(recordName: UUID().uuidString),
            scale: scale
        )
    }

    func tappedSavedConfigsButton() {
        isShowingSavedConfigsView = true
    }
}

struct ConfigCalculationView: View {
    @Bindable var viewModel = ConfigCalculationViewModel()

    var body: some View {
        Form {
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
                pixelShiftRow
            } header: {
                ControlSectionHeader()
            }
            Section {
                ResultRow(result: viewModel.result())
            }
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: viewModel.tappedSaveButton) {
                    Label("Save", systemImage: "folder.badge.plus")
                }
                .disabled(viewModel.disableSave)
            }
            ToolbarItem(placement: .navigation) {
                Button(action: viewModel.tappedSavedConfigsButton) {
                    Label("Saved Configs", systemImage: "folder")
                }
            }
        }
        .sheet(item: $viewModel.configToSave) { config in
            NavigationStack {
                ConfigSaveView()
                    .environment(config)
            }
        }
        .sheet(isPresented: $viewModel.isShowingSavedConfigsView) {
            NavigationStack {
                SavedConfigsView()
            }
        }
        .sheet(item: $viewModel.selectedComponent) { component in
            NavigationStack {
                ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: component))
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var imagingFocalLengthRow: some View {
        VStack(alignment: .leading) {
            LearnWhatThisIsFormRowButton {
                viewModel.selectedComponent = .imagingFocalLength
            } label: {
                FocalLengthRowHeader()
            }
            TextField(0.formatted(), value: $viewModel.imagingFocalLength, format: .number)
        }
    }

    private var imagingPixelSizeRow: some View {
        VStack(alignment: .leading) {
            LearnWhatThisIsFormRowButton {
                viewModel.selectedComponent = .imagingPixelSize
            } label: {
                PixelSizeRowHeader()
            }
            TextField(0.formatted(), value: $viewModel.imagingPixelSize, format: .number)
        }
    }

    private var guidingFocalLengthRow: some View {
        VStack(alignment: .leading) {
            LearnWhatThisIsFormRowButton {
                viewModel.selectedComponent = .guidingFocalLength
            } label: {
                FocalLengthRowHeader()
            }
            TextField(0.formatted(), value: $viewModel.guidingFocalLength, format: .number)
        }
    }

    private var guidingPixelSizeRow: some View {
        VStack(alignment: .leading) {
            LearnWhatThisIsFormRowButton {
                viewModel.selectedComponent = .guidingPixelSize
            } label: {
                PixelSizeRowHeader()
            }
            TextField(0.formatted(), value: $viewModel.guidingPixelSize, format: .number)
        }
    }

    private var scaleRow: some View {
        VStack(alignment: .leading) {
            LearnWhatThisIsFormRowButton {
                viewModel.selectedComponent = .scale
            } label: {
                ScaleRowHeader()
            }
            TextField(0.formatted(), value: $viewModel.scale, format: .number)
        }
    }

    private var pixelShiftRow: some View {
        VStack(alignment: .leading) {
            LearnWhatThisIsFormRowButton {
                viewModel.selectedComponent = .pixelShift
            } label: {
                MaxPixelShiftRowHeader()
            }
            .maxShiftInPixelsAccessibilityLabel()
            TextField(0.formatted(), value: $viewModel.maxPixelShift, format: .number)
        }
    }
}

#Preview {
    NavigationStack {
        ConfigCalculationView()
    }
}
