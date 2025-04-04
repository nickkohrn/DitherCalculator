//
//  CloseButton.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/26/25.
//

import SwiftUI

public struct CloseButton: UIViewRepresentable {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .close)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.addTarget(context.coordinator, action: #selector(Coordinator.perform), for: .primaryActionTriggered)
        return button
    }

    public func updateUIView(_ uiView: UIButton, context: Context) {
        context.coordinator.action = action
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    public class Coordinator {
        internal var action: () -> Void

        internal init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc internal func perform() {
            action()
        }
    }
}
