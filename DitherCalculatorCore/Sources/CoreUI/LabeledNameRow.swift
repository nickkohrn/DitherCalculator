//
//  LabeledNameRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 4/1/25.
//

import SwiftUI

public struct LabeledNameRow: View {
    public let name: String?

    public init(name: String?) {
        self.name = name
    }

    public var body: some View {
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
