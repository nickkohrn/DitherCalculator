//
//  ConfigDetailsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import CoreUI
import EditConfig
import Models
import SwiftUI

public struct ConfigDetailsView: View {
    @Environment(Config.self) private var config
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ConfigDetailsViewModel

    public init(viewModel: ConfigDetailsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        List {
            Section {
                LabeledNameRow(name: config.name)
            }
            Section {
                LabeledFocalLengthRow(value: config.imagingFocalLength.measurement)
                LabeledPixelSizeRow(value: config.imagingPixelSize.measurement)
            } header: {
                ImagingSectionHeader()
            }
            Section {
                LabeledFocalLengthRow(value: config.guidingFocalLength.measurement)
                LabeledPixelSizeRow(value: config.guidingPixelSize.measurement)
            } header: {
                GuidingSectionHeader()
            }
            Section {
                LabeledScaleRow(value: config.scale)
                LabeledMaxPixelShiftRow(value: config.maxPixelShift)
            } header: {
                ControlSectionHeader()
            }
            Section {
                LabeledResultRow(result: viewModel.result(for: config))
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DeleteButton { viewModel.tappedDeleteButton() }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", action: viewModel.tappedEditButton)
            }
        }
        .confirmationDialog(
            "Delete Config",
            isPresented: $viewModel.isShowingDeleteConfirmationDialog,
            titleVisibility: .visible,
            actions: {
                CancelButton { viewModel.tappedDeleteConfirmationCancelButton() }
                DeleteButton { viewModel.tappedDeleteConfirmationConfirm(for: config) }
            },
            message: {
                Text("Are you sure you want to delete this config? This cannot be undone.")
            }
        )
        .sheet(isPresented: $viewModel.isShowingEditView) {
            NavigationStack {
                EditConfigView()
                    .environment(config)
            }
        }
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue { dismiss() }
        }
        .disabled(viewModel.isDeleting)
    }
}

#if DEBUG
import CloudKit

#Preview {
    ConfigDetailsView(viewModel: ConfigDetailsViewModel(didDeleteConfig: {_ in }))
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
#endif
