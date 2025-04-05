//
//  SavedConfigsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import ConfigDetails
import CoreUI
import Models
import Observation
import SwiftUI
import Syncing

@MainActor
@Observable
public final class SavedConfigsViewModel {
    public var configs = [Config]()
    private var didPerformInitialFetch = false
    public var isLoading = false
    public var selectedConfig: Config?

    init() {}

    func didDeleteConfig(_ config: Config) {
        configs.removeAll { existing in
            existing.recordID == config.recordID
        }
    }

    private func fetchConfigs(using syncService: any SyncService) async {
        await MainActor.run { isLoading = true }

        do {
            let predicate = NSPredicate(value: true)
            let query = CKQuery(
                recordType: Config.Key.type.rawValue,
                predicate: predicate
            )
            query.sortDescriptors = [NSSortDescriptor(key: Config.Key.name.rawValue, ascending: true)]
            let result = try await syncService.records(
                matching: query,
                inZoneWith: nil,
                desiredKeys: nil,
                resultsLimit: CKQueryOperation.maximumResults
            )
            let records = result.matchResults.compactMap { try? $0.1.get() }
            let configs = records.compactMap(Config.init)

            await MainActor.run {
                self.configs = configs
                self.isLoading = false
                self.didPerformInitialFetch = true
            }
        } catch {
            print(error)
            await MainActor.run {
                self.isLoading = false
                self.didPerformInitialFetch = true
            }
        }
    }

    public func result(for config: Config) -> DitherResult? {
        try? ConfigCalculator.result(for: config)
    }

    func tapped(_ config: Config) {
        selectedConfig = config
    }

    func tappedRefreshButton(syncService: any SyncService) {
        Task {
            await fetchConfigs(using: syncService)
        }
    }

    func onAppear(syncService: any SyncService) {
        if didPerformInitialFetch { return }
        Task {
            await fetchConfigs(using: syncService)
        }
    }
}

struct SavedConfigsView: View {
    @Environment(CloudService.self) private var cloudService
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SavedConfigsViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading")
            } else {
                if viewModel.configs.isEmpty {
                    EmptyConfigsView()
                } else {
                    List {
                        ForEach(viewModel.configs) { config in
                            NavigationLink {
                                ConfigDetailsView(
                                    viewModel: ConfigDetailsViewModel(
                                        didDeleteConfig: { config in
                                            viewModel.didDeleteConfig(config)
                                        }
                                    )
                                )
                                .environment(config)
                            } label: {
                                LabeledContent {
                                    if let result = viewModel.result(for: config) {
                                        Text(result.formatted(.pixels))
                                    } else {
                                        MissingValuePlaceholder()
                                    }
                                } label: {
                                    if let name = config.name {
                                        Text(name)
                                    } else {
                                        UntitledPlaceholderView()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.onAppear(syncService: cloudService) }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton { dismiss() }
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    viewModel.tappedRefreshButton(syncService: cloudService)
                }, label: {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise.circle")
                            .accessibilityHint("Fetches your latest collection of configurations from iCloud")
                    }
                })
                .disabled(viewModel.isLoading)
            }
        }
        .onChange(of: viewModel.isLoading) { oldValue, newValue in
            guard oldValue != newValue else { return }
            announce(isLoading: newValue)
        }
    }

    private func announce(isLoading: Bool) {
        let string: LocalizedStringResource
        if isLoading {
            string = "Fetching configurations"
        } else {
            string = "Configurations fetched"
        }
        var announcement = AttributedString(localized: string)
        announcement.accessibilitySpeechAnnouncementPriority = .high
        AccessibilityNotification.Announcement(announcement).post()
    }
}

#Preview {
    NavigationStack {
        SavedConfigsView()
    }
}
