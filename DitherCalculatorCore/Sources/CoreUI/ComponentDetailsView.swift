//
//  ComponentDetailsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/26/25.
//

import Models
import SwiftUI

public struct ComponentDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    private let component: ConfigCalculator.Component

    public init(component: ConfigCalculator.Component) {
        self.component = component
    }

    public var body: some View {
        List {
            Section {
                Text(component.text)
            }
        }
        .navigationTitle(component.title)
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
        ComponentDetailsView(component: .imagingFocalLength)
    }
}

#Preview(ConfigCalculator.Component.imagingPixelSize.title) {
    NavigationStack {
        ComponentDetailsView(component: .imagingPixelSize)
    }
}

#Preview(ConfigCalculator.Component.guidingFocalLength.title) {
    NavigationStack {
        ComponentDetailsView(component: .guidingFocalLength)
    }
}

#Preview(ConfigCalculator.Component.guidingPixelSize.title) {
    NavigationStack {
        ComponentDetailsView(component: .guidingPixelSize)
    }
}

#Preview(ConfigCalculator.Component.scale.title) {
    NavigationStack {
        ComponentDetailsView(component: .scale)
    }
}

#Preview(ConfigCalculator.Component.pixelShift.title) {
    NavigationStack {
        ComponentDetailsView(component: .pixelShift)
    }
}
