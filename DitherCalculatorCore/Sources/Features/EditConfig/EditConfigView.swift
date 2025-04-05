//
//  EditConfigView.swift
//  DitherCalculatorCore
//
//  Created by Nick Kohrn on 4/4/25.
//

import CoreUI
import Models
import SwiftUI
import Syncing

public struct EditConfigView: View {
    @Environment(Config.self) private var config
    @Environment(CloudService.self) private var cloudService
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = EditConfigViewModel()

    public init() {}

    public var body: some View {
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
                LabeledResultRow(result: viewModel.result(for: config))
            }
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.selectedComponent) { component in
            NavigationStack {
                ComponentDetailsView(component: component)
            }
            .presentationDetents([.medium, .large])
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    SaveButton {
                        Task {
                            await viewModel.tappedSaveButton(
                                for: config,
                                syncService: cloudService
                            ) { updatedConfig in
                                config.updateWithValues(from: updatedConfig)
                            }
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
            if newValue { dismiss() }
        }
        .onChange(of: viewModel.result(for: config)) { oldValue, newValue in
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

#if DEBUG
import CloudKit

#Preview {
    NavigationStack {
        EditConfigView()
            .environment(
                Config(
                    guidingFocalLength: FocalLength(value: 200),
                    guidingPixelSize: PixelSize(value: 2.99),
                    imagingFocalLength: FocalLength(value: 382),
                    imagingPixelSize: PixelSize(value: 3.76),
                    maxPixelShift: 10,
                    name: "Starfront Rig",
                    recordID: CKRecord.ID(recordName: UUID().uuidString),
                    scale: 1
                )
            )
    }
}
#endif
