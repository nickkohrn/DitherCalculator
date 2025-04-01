//
//  DitherConfigUnavailableView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import SwiftUI

public struct EmptyConfigsView: View {
    public var body: some View {
        ContentUnavailableView(
            "No Configs",
            systemImage: "tray",
            description: Text("Saved configs will appear here.")
        )
    }
}

#Preview {
    EmptyConfigsView()
}
