//
//  ListRowHeader.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/27/25.
//

import SwiftUI

public struct FormRowHeader: View {
    public let string: String
    public let parenthesizedString: String?

    public init(string: String, parenthesizedString: String? = nil) {
        self.string = string
        self.parenthesizedString = parenthesizedString
    }

    public var body: some View {
        if let parenthesizedString = parenthesizedString {
            Text("\(Text(string).font(.caption).fontWeight(.semibold)) \(Text("(\(parenthesizedString))").font(.caption2).foregroundStyle(Color.primary.secondary))")
        } else {
            Text(string)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    FormRowHeader(string: "Focal Length", parenthesizedString: UnitLength.millimeters.symbol)
}
