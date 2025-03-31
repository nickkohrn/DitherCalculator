//
//  DitherConfigUnavailableView.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/30/25.
//

import SwiftUI

public struct DitherConfigsUnavailableView: View {
    public var body: some View {
        ContentUnavailableView("Configs Unavailable", systemImage: "document.badge.gearshape")
    }
}

#Preview {
    DitherConfigsUnavailableView()
}
