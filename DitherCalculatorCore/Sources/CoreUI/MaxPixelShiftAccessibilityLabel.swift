//
//  MaxShiftInPixelsAccessibilityLabel.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/29/25.
//

import SwiftUI

public struct MaxPixelShiftAccessibilityLabel: ViewModifier {
    public func body(content: Content) -> some View {
        content.accessibilityLabel("Maximum shift in pixels")
    }
}

extension View {
    public func maxPixelShiftAccessibilityLabel() -> some View {
        self.modifier(MaxPixelShiftAccessibilityLabel())
    }
}
