//
//  ConfigCalculationView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor @Observable
final class ConfigCalculationViewModel {
    var imagingFocalLength: Int?
    var configToSave: Config?
    var isShowingSavedConfigsView = false

    func tappedSaveButton() {
        guard let imagingFocalLength else { return }
        configToSave = Config(
            imagingFocalLength: imagingFocalLength,
            recordID: CKRecord.ID(recordName: UUID().uuidString)
        )
    }

    func tappedSavedConfigsButton() {
        isShowingSavedConfigsView = true
    }
}

struct ConfigCalculationView: View {
    @Bindable var viewModel = ConfigCalculationViewModel()

    var body: some View {
        Form {
            Section {
                TextField(0.formatted(), value: $viewModel.imagingFocalLength, format: .number)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                SaveButton(action: viewModel.tappedSaveButton)
            }
            ToolbarItem(placement: .navigation) {
                Button("Saved", action: viewModel.tappedSavedConfigsButton)
            }
        }
        .sheet(item: $viewModel.configToSave) { config in
            NavigationStack {
                ConfigSaveView()
                    .environment(config)
            }
        }
        .sheet(isPresented: $viewModel.isShowingSavedConfigsView) {
            NavigationStack {
                SavedConfigsView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConfigCalculationView()
    }
}
