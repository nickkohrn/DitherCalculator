//
//  ComponentDetailsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/26/25.
//

import CoreUI
import Foundation
import Models
import SwiftUI

@MainActor @Observable
public final class ComponentDetailsViewModel {
    public let component: ConfigCalculator.Component

    public init(component: ConfigCalculator.Component) {
        self.component = component
    }
}

public struct ComponentDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    private let viewModel: ComponentDetailsViewModel

    public init(viewModel: ComponentDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            Section {
                Text(viewModel.component.text)
            }
        }
        .navigationTitle(viewModel.component.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton { dismiss() }
            }
        }
    }
}

#Preview(ConfigCalculator.Component.imagingFocalLength.title) {
    NavigationStack {
        ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: .imagingFocalLength))
    }
}

#Preview(ConfigCalculator.Component.imagingPixelSize.title) {
    NavigationStack {
        ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: .imagingPixelSize))
    }
}

#Preview(ConfigCalculator.Component.guidingFocalLength.title) {
    NavigationStack {
        ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: .guidingFocalLength))
    }
}

#Preview(ConfigCalculator.Component.guidingPixelSize.title) {
    NavigationStack {
        ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: .guidingPixelSize))
    }
}

#Preview(ConfigCalculator.Component.scale.title) {
    NavigationStack {
        ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: .scale))
    }
}

#Preview(ConfigCalculator.Component.pixelShift.title) {
    NavigationStack {
        ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: .pixelShift))
    }
}
