//
//  DitherConfigEditView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor @Observable
public final class DitherConfigEditViewModel {
    private let syncService: any CloudSyncService
    public var config: DitherConfig
    public var name = ""
    public var imagingFocalLength: Double?
    public var imagingPixelSize: Double?
    public var guidingFocalLength: Double?
    public var guidingPixelSize: Double?
    public var scale: Double?
    public var maxPixelShift: Double?
    public var selectedComponent: CalculationComponent?
    public var isSaving = false
    public var shouldDismiss = false
    public let didEditConfig: (DitherConfig) -> Void

    public var disableSaveButton: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines) == config.name.trimmingCharacters(in: .whitespacesAndNewlines)
        && imagingFocalLength == config.imagingFocalLength
        && imagingPixelSize == config.imagingPixelSize
        && guidingFocalLength == config.guidingFocalLength
        && guidingPixelSize == config.guidingPixelSize
        && scale == config.scale
        && maxPixelShift == config.maxPixelShift
    }

    public init(
        syncService: any CloudSyncService,
        config: DitherConfig,
        didEditConfig: @escaping (DitherConfig) -> Void
    ) {
        self.syncService = syncService
        self.config = config
        self.didEditConfig = didEditConfig
        name = config.name
        imagingFocalLength = config.imagingFocalLength
        imagingPixelSize = config.imagingPixelSize
        guidingFocalLength = config.guidingFocalLength
        guidingPixelSize = config.guidingPixelSize
        scale = config.scale
        maxPixelShift = config.maxPixelShift
    }

    public func tappedSaveButton() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !trimmedName.isEmpty,
            let imagingFocalLength,
            let imagingPixelSize,
            let guidingFocalLength,
            let guidingPixelSize,
            let scale,
            let maxPixelShift
        else { return }
        isSaving = true
        Task {
            do {
                let status = try await syncService.accountStatus()
                switch status {
                case .couldNotDetermine:
                    print("CloudKit: couldNotDetermine")
                case .available:
                    print("CloudKit: available")
                    let record = try await syncService.record(for: config.recordID)
                    print(record)
                    guard record.recordType == DitherConfig.Key.type.rawValue else { return }
                    record[DitherConfig.Key.name.rawValue] = trimmedName
                    record[DitherConfig.Key.imagingFocalLength.rawValue] = imagingFocalLength
                    record[DitherConfig.Key.imagingPixelSize.rawValue] = imagingPixelSize
                    record[DitherConfig.Key.guidingFocalLength.rawValue] = guidingFocalLength
                    record[DitherConfig.Key.guidingPixelSize.rawValue] = guidingPixelSize
                    record[DitherConfig.Key.scale.rawValue] = scale
                    record[DitherConfig.Key.maxPixelShift.rawValue] = maxPixelShift
                    try await syncService.save(record)
                    await MainActor.run {
                        guard let config = DitherConfig(from: record) else {
                            print("Could not update config")
                            return
                        }
                        didEditConfig(config)
                        shouldDismiss = true
                    }
                case .restricted:
                    print("CloudKit: restricted")
                case .noAccount:
                    print("CloudKit: noAccount")
                case .temporarilyUnavailable:
                    print("CloudKit: temporarilyUnavailable")
                @unknown default:
                    print("CloudKit: unknown")
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    print(error)
                }
                return
            }
        }
    }
}

public struct DitherConfigEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var viewModel: DitherConfigEditViewModel

    public init(viewModel: DitherConfigEditViewModel) {
        _viewModel = Bindable(viewModel)
    }

    public var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Name", text: $viewModel.name)
                }
            }
            Section {
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
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
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
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            } header: {
                ImagingSectionHeader()
            }
            Section {
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
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
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
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            } header: {
                GuidingSectionHeader()
            }
            Section {
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
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
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
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            } header: {
                ControlSectionHeader()
            }
        }
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CancelButton { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    SaveButton(action: viewModel.tappedSaveButton)
                        .disabled(viewModel.disableSaveButton)
                }
            }
        }
        .sheet(item: $viewModel.selectedComponent) { component in
            NavigationStack {
                ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: component))
            }
            .presentationDetents([.medium, .large])
        }
        .onChange(of: viewModel.shouldDismiss, { _, newValue in
            if newValue { dismiss() }
        })
        .disabled(viewModel.isSaving)
    }
}

#Preview {
    let cloudSyncService = MockCloudSyncService(
        accountStatus: .success(.available),
        recordForID: .success(DitherConfig(
            imagingFocalLength: 382,
            imagingPixelSize: 3.76,
            guidingFocalLength: 200,
            guidingPixelSize: 2.99,
            scale: 1,
            maxPixelShift: 10,
            name: "Starfront Rig",
            recordID: CKRecord.ID(recordName: UUID().uuidString)
        ).newCKRecord())
    )
    NavigationStack {
        DitherConfigEditView(
            viewModel: DitherConfigEditViewModel(
                syncService: cloudSyncService,
                config: DitherConfig(
                    imagingFocalLength: 382,
                    imagingPixelSize: 3.76,
                    guidingFocalLength: 200,
                    guidingPixelSize: 2.99,
                    scale: 1,
                    maxPixelShift: 10,
                    name: "Starfront Rig",
                    recordID: CKRecord.ID(recordName: UUID().uuidString)
                ),
                didEditConfig: { _ in }
            )
        )
    }
}
