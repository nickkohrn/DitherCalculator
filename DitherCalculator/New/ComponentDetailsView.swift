//
//  ComponentDetailsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/26/25.
//

import Foundation
import SwiftUI

@MainActor @Observable
public final class ComponentDetailsViewModel {
    public let component: CalculationComponent

    public init(component: CalculationComponent) {
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
                CloseButton {
                    dismiss()
                }
            }
        }
    }
}

#Preview(CalculationComponent.imagingFocalLength.title) {
    NavigationStack {
        ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: .imagingFocalLength))
    }
}

#Preview(CalculationComponent.imagingPixelSize.title) {
    NavigationStack {
        ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: .imagingPixelSize))
    }
}

#Preview(CalculationComponent.guidingFocalLength.title) {
    NavigationStack {
        ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: .guidingFocalLength))
    }
}

#Preview(CalculationComponent.guidingPixelSize.title) {
    NavigationStack {
        ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: .guidingPixelSize))
    }
}

#Preview(CalculationComponent.scale.title) {
    NavigationStack {
        ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: .scale))
    }
}

#Preview(CalculationComponent.pixelShift.title) {
    NavigationStack {
        ComponentDetailsView(viewModel: ComponentDetailsViewModel(component: .pixelShift))
    }
}
