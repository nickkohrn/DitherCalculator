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
    var selectedConfig: Config?
    var configs = [Config]()

    func tapped(_ config: Config) {
        selectedConfig = config
    }

    func task() async {
        Task {
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
            } catch {
                print(error)
            }
        }
    }
}

struct SavedConfigsView: View {
    @State private var viewModel = SavedConfigsViewModel()

    var body: some View {
        List {
            ForEach(viewModel.configs) { config in
                NavigationLink {
                    ConfigDetailsView()
                        .environment(config)
                } label: {
                    Text(config.imagingFocalLength.formatted())
                }
            }
        }
        .task { await viewModel.task() }
    }
}

#Preview {
    NavigationStack {
        SavedConfigsView()
    }
}
