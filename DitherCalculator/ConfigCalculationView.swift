//
//  ConfigCalculationView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Models
import Observation
import SwiftUI

@MainActor @Observable
public final class ConfigCalculationViewModel {
    public var config = Config(
        guidingFocalLength: FocalLength(value: nil),
        guidingPixelSize: PixelSize(value: nil),
        imagingFocalLength: FocalLength(value: nil),
        imagingPixelSize: PixelSize(value: nil),
        maxPixelShift: nil,
        name: nil,
        recordID: CKRecord.ID(recordName: UUID().uuidString),
        scale: nil
    )

    var isShowingSaveConfigView = false
    var isShowingSavedConfigsView = false
    var selectedComponent: ConfigCalculator.Component?

    var disableSave: Bool {
        result() == nil
    }

    func result() -> DitherResult? {
        try? ConfigCalculator.result(for: config)
    }

    func tappedSaveButton() {
        isShowingSaveConfigView = true
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
                    value: $viewModel.config.imagingFocalLength.value,
                    onHeaderTap: { viewModel.selectedComponent = .imagingFocalLength }
                )
                PixelSizeFormRow(
                    value: $viewModel.config.imagingPixelSize.value,
                    onHeaderTap: { viewModel.selectedComponent = .imagingPixelSize }
                )
            } header: {
                ImagingSectionHeader()
            }
            Section {
                FocalLengthFormRow(
                    value: $viewModel.config.guidingFocalLength.value,
                    onHeaderTap: { viewModel.selectedComponent = .guidingFocalLength }
                )
                PixelSizeFormRow(
                    value: $viewModel.config.guidingPixelSize.value,
                    onHeaderTap: { viewModel.selectedComponent = .guidingPixelSize }
                )
            } header: {
                GuidingSectionHeader()
            }
            Section {
                ScaleFormRow(
                    value: $viewModel.config.scale,
                    onHeaderTap: { viewModel.selectedComponent = .scale }
                )
                MaxPixelShiftFormRow(
                    value: $viewModel.config.maxPixelShift,
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
        .sheet(isPresented: $viewModel.isShowingSaveConfigView) {
            NavigationStack {
                ConfigSaveView()
                    .environment(viewModel.config)
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
