//
//  CloseButton.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/26/25.
//

import SwiftUI

//struct CloseButton: UIViewRepresentable {
//    private let action: () -> Void
//
//    init(action: @escaping () -> Void) {
//        self.action = action
//    }
//
//    func makeUIView(context: Context) -> UIButton {
//        let button = UIButton(type: .close)
//        button.setContentCompressionResistancePriority(.required, for: .horizontal)
//        button.setContentCompressionResistancePriority(.required, for: .vertical)
//        button.setContentHuggingPriority(.required, for: .horizontal)
//        button.setContentHuggingPriority(.required, for: .vertical)
//        button.addTarget(context.coordinator, action: #selector(Coordinator.perform), for: .primaryActionTriggered)
//        return button
//    }
//
//    func updateUIView(_ uiView: UIButton, context: Context) {
//        context.coordinator.action = action
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(action: action)
//    }
//
//    class Coordinator {
//        var action: () -> Void
//
//        init(action: @escaping () -> Void) {
//            self.action = action
//        }
//
//        @objc func perform() {
//            action()
//        }
//    }
//}
