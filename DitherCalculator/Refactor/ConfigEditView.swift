//
//  ConfigEditView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor @Observable
final class ConfigEditViewModel {
    private var existingConfig: Config?
    var guidingFocalLength: Int?
    var guidingPixelSize: Double?
    var imagingFocalLength: Int?
    var imagingPixelSize: Double?
    var isSaving = false
    var maxPixelShift: Int?
    var name = ""
    var scale: Double?
    var selectedComponent: CalculationComponent?
    var shouldDismiss = false

    var disableSave: Bool {
        guard let existingConfig,
              let guidingFocalLength,
              let guidingPixelSize,
              let imagingFocalLength,
              let imagingPixelSize,
              let maxPixelShift,
              let scale else {
            return true
        }
        return guidingFocalLength == existingConfig.guidingFocalLength
        && guidingPixelSize == existingConfig.guidingPixelSize
        && imagingFocalLength == existingConfig.imagingFocalLength
        && imagingPixelSize == existingConfig.imagingPixelSize
        && maxPixelShift == existingConfig.maxPixelShift
        && scale == existingConfig.scale
        && (trimmedName.isEmpty || trimmedName == existingConfig.name?.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init() {}

    func onAppear(with config: Config) {
        _existingConfig = config
        guidingFocalLength = config.guidingFocalLength
        guidingPixelSize = config.guidingPixelSize
        imagingFocalLength = config.imagingFocalLength
        imagingPixelSize = config.imagingPixelSize
        maxPixelShift = config.maxPixelShift
        name = config.name ?? ""
        scale = config.scale
    }

    public func result() -> DitherResult? {
        guard
            let imagingFocalLength,
            let imagingPixelSize,
            let guidingFocalLength,
            let guidingPixelSize,
            let scale,
            let maxPixelShift
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

    func tappedSaveButton(for config: Config, onSuccess: @escaping (Config) -> Void) {
        Task {
            await MainActor.run {
                isSaving = true
            }
            do {
                let record = try await CKContainer.default().privateCloudDatabase.record(for: config.recordID)
                guard record.recordType == Config.Key.type.rawValue else { return }
                record[Config.Key.guidingFocalLength.rawValue] = guidingFocalLength
                record[Config.Key.guidingPixelSize.rawValue] = guidingPixelSize
                record[Config.Key.imagingFocalLength.rawValue] = imagingFocalLength
                record[Config.Key.imagingPixelSize.rawValue] = imagingPixelSize
                record[Config.Key.maxPixelShift.rawValue] = maxPixelShift
                record[Config.Key.name.rawValue] = trimmedName
                record[Config.Key.scale.rawValue] = scale
                try await CKContainer.default().privateCloudDatabase.save(record)
                await MainActor.run {
                    guard let config = Config(from: record) else {
                        print("Failed to initialize Config from CKRecord")
                        return
                    }
                    onSuccess(config)
                    shouldDismiss = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    print(error)
                }
            }
        }
    }
}

struct ConfigEditView: View {
    @Environment(Config.self) private var config
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ConfigEditViewModel()

    var body: some View {
        Form {
            Section {
                NameFormRow(value: $viewModel.name)
            }
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
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.selectedComponent) { component in
            NavigationStack {
                ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: component))
            }
            .presentationDetents([.medium, .large])
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Button("Save") {
                        viewModel.tappedSaveButton(for: config) { updatedConfig in
                            config.updateWithValues(from: updatedConfig)
                        }
                    }
                    .disabled(viewModel.disableSave)
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                CancelButton { dismiss() }
            }
        }
        .onAppear { viewModel.onAppear(with: config) }
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue {
                dismiss()
            }
        }
        .onChange(of: viewModel.result()) { oldValue, newValue in
            guard oldValue != newValue else { return }
            announce(result: newValue)
        }
        .disabled(viewModel.isSaving)
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
        ConfigEditView()
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
}
