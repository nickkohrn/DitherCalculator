//
//  SaveButton.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import SwiftUI

public struct SaveButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button("Save", action: action)
    }
}

#Preview {
    SaveButton {}
}
