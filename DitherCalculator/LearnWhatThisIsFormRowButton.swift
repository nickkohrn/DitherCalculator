//
//  LearnWhatThisIsFormRowButton.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import SwiftUI

struct LearnWhatThisIsFormRowButton<Label: View>: View {
    let action: () -> Void
    let label: () -> Label

    init(
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.label = label
    }

    var body: some View {
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
