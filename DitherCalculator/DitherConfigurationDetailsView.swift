//
//  DitherConfigurationDetailsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//

import Observation
import SwiftUI

@MainActor
@Observable
public final class DitherConfigurationDetailsViewModel {
    private let configuration: DitherConfiguration

    public init(configuration: DitherConfiguration) {
        self.configuration = configuration
    }
}

public struct DitherConfigurationDetailsView: View {
    private let viewModel: DitherConfigurationDetailsViewModel

    public init(viewModel: DitherConfigurationDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            Section {
                
            } header: {
                Label("Imaging", systemImage: "camera")
            }
        }
    }
}

#Preview {
    DitherConfigurationDetailsView(
        viewModel: DitherConfigurationDetailsViewModel(
            configuration: DitherConfiguration(
                imagingFocalLength: 382,
                imagingPixelSize: 3.76,
                guidingFocalLength: 200,
                guidingPixelSize: 2.99,
                scale: 1,
                maximumPixelShift: 10,
                name: "Starfront Rig",
                uuidString: UUID().uuidString
            )
        )
    )
}
