//
//  SavedConfigurationsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor
@Observable
public final class SavedConfigurationsViewModel {
    private let cloudService: any CloudService
    public private(set) var configurations = [DitherConfiguration]()
    public var isLoading = false
    public var selectedConfiguration: DitherConfiguration?

    public init(cloudService: any CloudService) {
        self.cloudService = cloudService
    }

    private func fetchSavedConfiguratios() async throws {
        configurations = try await cloudService.fetchDitherConfigurations()
    }

    public func task(cloudService: any CloudService) async {
        defer { isLoading = false }
        isLoading = true
        do {
            try await fetchSavedConfiguratios()
        } catch {
            print("Error:", error)
        }
    }

    public func tappedConfiguration(_ configuration: DitherConfiguration) {
        selectedConfiguration = configuration
    }
}

public struct SavedConfigurationsView: View {
    @Environment(\.cloudKitService) private var cloudKitService
    @Environment(\.dismiss) private var dismiss
    @Bindable private var viewModel: SavedConfigurationsViewModel

    public init(viewModel: SavedConfigurationsViewModel) {
        _viewModel = Bindable(viewModel)
    }

    public var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading")
            } else {
                if viewModel.configurations.isEmpty {
                    ContentUnavailableView("No Saved Configurations", systemImage: "list.bullet")
                } else {
                    List {
                        Section {
                            ForEach(viewModel.configurations, id: \.self) { configuration in
                                Button {
                                    viewModel.tappedConfiguration(configuration)
                                } label: {
                                    SavedConfigurationRowView(
                                        viewModel: SavedConfigurationRowViewModel(configuration: configuration)
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
        .animation(.default, value: viewModel.configurations)
        .task{ await viewModel.task(cloudService: cloudKitService) }
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton { dismiss() }
            }
        }
        .sheet(item: $viewModel.selectedConfiguration) { configuration in
            NavigationStack {
                DitherConfigurationDetailsView(
                    viewModel: DitherConfigurationDetailsViewModel(configuration: configuration)
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        SavedConfigurationsView(
            viewModel: SavedConfigurationsViewModel(
                cloudService: MockCloudService(
                    accountStatus: .available,
                    configurations: [
                        DitherConfiguration(
                            imagingFocalLength: 382,
                            imagingPixelSize: 3.76,
                            guidingFocalLength: 200,
                            guidingPixelSize: 2.99,
                            scale: 1,
                            maximumPixelShift: 10,
                            name: "Starfront Rig",
                            uuidString: UUID().uuidString,
                            recordID: CKRecord.ID(recordName: "")
                        )
                    ],
                    save: {},
                    recordForDitherConfiguration: DitherConfiguration(
                        imagingFocalLength: 382,
                        imagingPixelSize: 3.76,
                        guidingFocalLength: 200,
                        guidingPixelSize: 2.99,
                        scale: 1,
                        maximumPixelShift: 10,
                        name: "Starfront Rig",
                        uuidString: UUID().uuidString,
                        recordID: CKRecord.ID(recordName: "")
                    ).record
                )
            )
        )
    }
}

public protocol CloudService {
    func checkAccountStatus() async throws -> CKAccountStatus
    func record(for ditherConfiguration: DitherConfiguration) async throws -> CKRecord?
    func fetchDitherConfigurations() async throws -> [DitherConfiguration]
    func save(_ record: CKRecord) async throws
}

final class MockCloudService: CloudService {
    let accountStatus: CKAccountStatus
    let configurations: [DitherConfiguration]
    let save: () throws -> Void
    let recordForDitherConfiguration: CKRecord?

    init(
        accountStatus: CKAccountStatus,
        configurations: [DitherConfiguration],
        save: @escaping () -> Void,
        recordForDitherConfiguration: CKRecord?
    ) {
        self.accountStatus = accountStatus
        self.configurations = configurations
        self.save = save
        self.recordForDitherConfiguration = recordForDitherConfiguration
    }

    func checkAccountStatus() async throws -> CKAccountStatus {
        accountStatus
    }
    
    func fetchDitherConfigurations() async throws -> [DitherConfiguration] {
        configurations
    }
    
    func save(_ record: CKRecord) async throws {
        try save()
    }

    func record(for ditherConfiguration: DitherConfiguration) async throws -> CKRecord? {
        recordForDitherConfiguration
    }
}
