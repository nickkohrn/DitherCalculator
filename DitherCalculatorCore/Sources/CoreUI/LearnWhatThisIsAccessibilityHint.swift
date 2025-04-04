//
//  LearnWhatThisIsAccessibilityHint.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//

import SwiftUI

struct LearnWhatThisIsAccessibilityHint: ViewModifier {
    func body(content: Content) -> some View {
        content.accessibilityHint("Learn what this is")
    }
}

extension View {
    public func learnWhatThisIsAccessibilityHint() -> some View {
        self.modifier(LearnWhatThisIsAccessibilityHint())
    }
}
