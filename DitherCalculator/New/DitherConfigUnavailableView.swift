//
//  DitherConfigUnavailableView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import SwiftUI

public struct DitherConfigUnavailableView: View {
    public var body: some View {
        ContentUnavailableView("Configuration Unavailable", systemImage: "document.badge.gearshape")
    }
}

#Preview {
    DitherConfigUnavailableView()
}
