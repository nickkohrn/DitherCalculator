//
//  DeleteButton.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import SwiftUI

public struct DeleteButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button("Delete", systemImage: "trash", role: .destructive, action: action)
    }
}

#Preview {
    DeleteButton {}
}
