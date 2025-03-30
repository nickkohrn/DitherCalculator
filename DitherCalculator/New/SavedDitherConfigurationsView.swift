//
//  SavedDitherConfigurationsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor
@Observable
public final class SavedDitherConfigurationsViewModel {
    private let cloudService: any CloudSyncService
    public private(set) var configs = [DitherConfig]()
    public var isLoading = false
    public var selectedConfig: DitherConfig?

    public init(cloudService: any CloudSyncService) {
        self.cloudService = cloudService
    }

    public func task() async {
        defer { isLoading = false }
        await MainActor.run {
            isLoading = true
        }
        do {
            let status = try await cloudService.accountStatus()
            switch status {
            case .couldNotDetermine:
                print("CloudKit status: couldNotDetermine")
            case .available:
                print("CloudKit status: available")
                let configs = try await cloudService.fetchDitherConfigs()
                await MainActor.run {
                    self.configs = configs
                }
            case .restricted:
                print("CloudKit status: restricted")
            case .noAccount:
                print("CloudKit status: noAccount")
            case .temporarilyUnavailable:
                print("CloudKit status: temporarilyUnavailable")
            @unknown default:
                print("CloudKit status: unknown")
            }
        } catch {
            print("Error:", error)
        }
    }

    public func tappedConfiguration(_ config: DitherConfig) {
        selectedConfig = config
    }
}

public struct SavedDitherConfigurationsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var viewModel: SavedDitherConfigurationsViewModel

    public init(viewModel: SavedDitherConfigurationsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            if viewModel.configs.isEmpty {
                DitherConfigUnavailableView()
            } else {
                List {
                    Section {
                        ForEach(viewModel.configs) { config in
                            Button {
                                viewModel.tappedConfiguration(config)
                            } label: {
                                SavedDitherConfigRowView(viewModel: SavedDitherConfigRowViewModel(config: config))
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Saved Configs")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.selectedConfig) { config in
            NavigationStack {
                DitherConfigDetailsView(viewModel: DitherConfigDetailsViewModel(config: config))
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton { dismiss() }
            }
        }
        .task { await viewModel.task() }
    }
}

#Preview("Available") {
    NavigationStack {
        SavedDitherConfigurationsView(
            viewModel: SavedDitherConfigurationsViewModel(
                cloudService: MockCloudSyncService(
                    accountStatus: .success(.available),
                    fetchDitherConfigsResult: .success([DitherConfig(
                        imagingFocalLength: 382,
                        imagingPixelSize: 3.76,
                        guidingFocalLength: 200,
                        guidingPixelSize: 2.99,
                        scale: 1,
                        maxPixelShift: 10,
                        name: "Starfront Rig",
                        recordID: CKRecord.ID(recordName: UUID().uuidString)
                    )])
                )
            )
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        SavedDitherConfigurationsView(
            viewModel: SavedDitherConfigurationsViewModel(
                cloudService: MockCloudSyncService(
                    accountStatus: .success(.available),
                    fetchDitherConfigsResult: .success([])
                )
            )
        )
    }
}
