//
//  SavedConfigsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor @Observable
final class SavedConfigsViewModel {
    var configs = [Config]()
    var didPerformInitialFetch = false
    var isLoading = false
    var selectedConfig: Config?

    init() {}

    func didDeleteConfig(_ config: Config) {
        configs.removeAll { existing in
            existing.recordID == config.recordID
        }
    }

    private func fetchConfigs() async {
        await MainActor.run {
            isLoading = true
        }
        do {
            let predicate = NSPredicate(value: true)
            let query = CKQuery(
                recordType: Config.Key.type.rawValue,
                predicate: predicate
            )
            query.sortDescriptors = [NSSortDescriptor(key: Config.Key.imagingFocalLength.rawValue, ascending: true)]
            let result = try await CKContainer.default().privateCloudDatabase.records(matching: query)
            let records = result.matchResults.compactMap { try? $0.1.get() }
            configs = records.compactMap(Config.init)
            await MainActor.run {
                isLoading = false
                didPerformInitialFetch = true
            }
        } catch {
            print(error)
            await MainActor.run {
                isLoading = false
                didPerformInitialFetch = true
            }
        }
    }

    public func result(for config: Config) -> DitherResult? {
        guard
            let imagingFocalLength = config.imagingFocalLength,
            let imagingPixelSize = config.imagingPixelSize,
            let guidingFocalLength = config.guidingFocalLength,
            let guidingPixelSize = config.guidingPixelSize,
            let scale = config.scale,
            let maxPixelShift = config.maxPixelShift
        else { return nil }
        let result = try? DitherCalculator.calculateDitherPixels(with: DitherParameters(
            imagingMetadata: EquipmentMetadata(
                focalLength: imagingFocalLength.measurement.value,
                pixelSize: imagingPixelSize.measurement.value
            ),
            guidingMetadata: EquipmentMetadata(
                focalLength: guidingFocalLength.measurement.value,
                pixelSize: guidingPixelSize.measurement.value
            ),
            desiredImagingShiftPixels: maxPixelShift,
            scale: scale
        ))
        return result
    }

    func tapped(_ config: Config) {
        selectedConfig = config
    }

    func tappedRefreshButton() {
        Task {
            await fetchConfigs()
        }
    }

    func task() async {
        if didPerformInitialFetch { return }
        await fetchConfigs()
    }
}

struct SavedConfigsView: View {
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
        .task { await viewModel.task() }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton { dismiss() }
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: viewModel.tappedRefreshButton) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise.circle")
                            .accessibilityHint("Fetches your latest collection of configurations from iCloud")
                    }
                }
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
