//
//  LabeledNameRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

struct LabeledNameRow: View {
    let name: String?

    var body: some View {
        LabeledContent("Name") {
            if let name {
                Text(name)
            } else {
                UntitledPlaceholderView()
            }
        }
    }
}

#Preview {
    LabeledNameRow(name: nil)
    LabeledNameRow(name: "Starfront Rig")
}
