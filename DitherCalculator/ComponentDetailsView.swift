//
//  ComponentDetailsView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/26/25.
//

import SwiftUI

struct ComponentDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    let component: CalculationComponent

    var body: some View {
        List {
            Section {
                Text(component.text)
            }
        }
        .navigationTitle(component.title)
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
        ComponentDetailsView(component: .imagingFocalLength)
    }
}

#Preview(CalculationComponent.imagingPixelSize.title) {
    NavigationStack {
        ComponentDetailsView(component: .imagingPixelSize)
    }
}

#Preview(CalculationComponent.guidingFocalLength.title) {
    NavigationStack {
        ComponentDetailsView(component: .guidingFocalLength)
    }
}

#Preview(CalculationComponent.guidingPixelSize.title) {
    NavigationStack {
        ComponentDetailsView(component: .guidingPixelSize)
    }
}

#Preview(CalculationComponent.scale.title) {
    NavigationStack {
        ComponentDetailsView(component: .scale)
    }
}

#Preview(CalculationComponent.pixelShift.title) {
    NavigationStack {
        ComponentDetailsView(component: .pixelShift)
    }
}
