//
//  LearnWhatThisIsFormRowButton.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import SwiftUI

public struct LearnWhatThisIsFormRowButton<Label: View>: View {
    private let action: () -> Void
    private let label: () -> Label

    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(action: action) {
            label()
                .foregroundStyle(Color.accentColor)
        }
        .buttonStyle(.plain)
        .learnWhatThisIsAccessibilityHint()
    }
}

#Preview {
    LearnWhatThisIsFormRowButton(action: {}) {
        Text("Focal Length (mm)")
    }
}
