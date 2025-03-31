//
//  ConfigEditView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor @Observable
final class ConfigEditViewModel {
    var imagingFocalLength: Int?
    var shouldDismiss = false

    init(imagingFocalLength: Int? = nil) {
        self.imagingFocalLength = imagingFocalLength
    }

    func onAppear(with config: Config) {
        imagingFocalLength = config.imagingFocalLength
    }

    func tappedSaveButton(for config: Config, onSuccess: @escaping (Config) -> Void) {
        Task {
            do {
                let record = try await CKContainer.default().privateCloudDatabase.record(for: config.recordID)
                guard record.recordType == Config.Key.type.rawValue else { return }
                record[Config.Key.imagingFocalLength.rawValue] = imagingFocalLength
                try await CKContainer.default().privateCloudDatabase.save(record)
                await MainActor.run {
                    guard let config = Config(from: record) else {
                        print("Failed to initialize Config from CKRecord")
                        return
                    }
                    onSuccess(config)
                    shouldDismiss = true
                }
            } catch {
                print(error)
            }
        }
    }
}

struct ConfigEditView: View {
    @Environment(Config.self) private var config
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ConfigEditViewModel()

    var body: some View {
        Form {
            TextField(0.formatted(), value: $viewModel.imagingFocalLength, format: .number)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.tappedSaveButton(for: config) { updatedConfig in
                        config.updateWithValues(from: updatedConfig)
                    }
                }
            }
        }
        .onAppear { viewModel.onAppear(with: config) }
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

#Preview {
    ConfigEditView()
}
