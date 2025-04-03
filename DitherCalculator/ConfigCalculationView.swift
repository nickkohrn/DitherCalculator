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
    var guidingFocalLength: Double?
    var guidingPixelSize: Double?
    var imagingFocalLength: Double?
    var imagingPixelSize: Double?
    var isShowingSavedConfigsView = false
    var maxPixelShift: Double?
    var scale: Double?
    var selectedComponent: CalculationComponent?

    var disableSave: Bool {
        result() == nil
    }

    func result() -> DitherResult? {
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
            name: "",
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
                FocalLengthFormRow(
                    value: $viewModel.imagingFocalLength,
                    onHeaderTap: { viewModel.selectedComponent = .imagingFocalLength }
                )
                PixelSizeFormRow(
                    value: $viewModel.imagingPixelSize,
                    onHeaderTap: { viewModel.selectedComponent = .imagingPixelSize }
                )
            } header: {
                ImagingSectionHeader()
            }
            Section {
                FocalLengthFormRow(
                    value: $viewModel.guidingFocalLength,
                    onHeaderTap: { viewModel.selectedComponent = .guidingFocalLength }
                )
                PixelSizeFormRow(
                    value: $viewModel.guidingPixelSize,
                    onHeaderTap: { viewModel.selectedComponent = .guidingPixelSize }
                )
            } header: {
                GuidingSectionHeader()
            }
            Section {
                ScaleFormRow(
                    value: $viewModel.scale,
                    onHeaderTap: { viewModel.selectedComponent = .scale }
                )
                MaxPixelShiftFormRow(
                    value: $viewModel.maxPixelShift,
                    onHeaderTap: { viewModel.selectedComponent = .pixelShift }
                )
            } header: {
                ControlSectionHeader()
            }
            Section {
                LabeledResultRow(result: viewModel.result())
            }
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: viewModel.tappedSaveButton) {
                    Label("Save to iCloud", systemImage: "icloud.and.arrow.up")
                }
                .disabled(viewModel.disableSave)
            }
            ToolbarItem(placement: .navigation) {
                Button(action: viewModel.tappedSavedConfigsButton) {
                    Label("Saved Configs", systemImage: "tray.full")
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
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $viewModel.selectedComponent) { component in
            NavigationStack {
                ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: component))
            }
            .presentationDetents([.medium, .large])
        }
        .onChange(of: viewModel.result()) { oldValue, newValue in
            guard oldValue != newValue else { return }
            announce(result: newValue)
        }
    }

    private func announce(result: DitherResult?) {
        let string: LocalizedStringResource
        if let result {
            string = "Result: \(result.formatted(.pixels))"
        } else {
            // This should occur only when transitioning from a valid result to `nil` rather than
            // whenever a calculation component's value is modified.
            string = "No result; form incomplete"
        }
        var announcement = AttributedString(localized: string)
        announcement.accessibilitySpeechAnnouncementPriority = .low
        AccessibilityNotification.Announcement(announcement).post()
    }
}

#Preview {
    NavigationStack {
        ConfigCalculationView()
    }
}
