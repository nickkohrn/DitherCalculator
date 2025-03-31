//
//  ConfigDetailsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import CloudKit
import Observation
import SwiftUI

@MainActor @Observable
final class ConfigDetailsViewModel {
    public var isShowingEditView = false

    func tappedEditButton() {
        isShowingEditView = true
    }
}

struct ConfigDetailsView: View {
    @Environment(Config.self) private var config
    @State private var viewModel = ConfigDetailsViewModel()

    var body: some View {
        List {
            LabeledContent("Focal Length", value: config.imagingFocalLength.formatted())
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", action: viewModel.tappedEditButton)
            }
        }
        .sheet(isPresented: $viewModel.isShowingEditView) {
            NavigationStack {
                ConfigEditView()
                    .environment(config)
            }
        }
    }
}

#Preview {
    ConfigDetailsView()
}
