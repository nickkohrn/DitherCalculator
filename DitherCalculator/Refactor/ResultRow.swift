//
//  ResultRow.swift
//  DitherCalculator
//
//  Created by Nick Kohrn on 3/31/25.
//

import SwiftUI

struct ResultRow: View {
    let result: Int?

    var body: some View {
        LabeledContent("Result") {
            if let result {
                Text("^[\(result) pixel](inflect: true)")
            } else {
                Text("^[\(0) pixel](inflect: true)")
            }
        }
    }
}

#Preview {
    ResultRow(result: nil)
    ResultRow(result: 1)
    ResultRow(result: 10)
}
