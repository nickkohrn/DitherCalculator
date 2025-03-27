//
//  ListRowHeader.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/27/25.
//

import SwiftUI


struct FormRowHeader<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .font(.caption)
            .fontWeight(.semibold)
    }
}

#Preview {
    FormRowHeader {
        Text("Focal Length \(Text("(\(UnitLength.millimeters.symbol))").font(.caption2).foregroundStyle(Color.primary.secondary))")
    }
}
