//
//  ConfigDetailsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor @Observable
final class ConfigSaveViewModel {
    public var shouldDismiss = false

    init() {}

    func tappedSaveButton(for config: Config) {
        let record = config.newCKRecord()
        Task {
            do {
                try await CKContainer.default().privateCloudDatabase.save(record)
                await MainActor.run {
                    shouldDismiss = true
                }
            } catch {
                print(error)
            }
        }
    }
}

struct ConfigSaveView: View {
    @Environment(Config.self) private var config
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ConfigSaveViewModel()

    var body: some View {
        Form {
            if let value = config.imagingFocalLength {
                Text(value.formatted())
            } else {
                Text("--")
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.tappedSaveButton(for: config)
                }
            }
        }
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue { dismiss() }
        }
    }
}

#Preview {
    ConfigSaveView()
}
